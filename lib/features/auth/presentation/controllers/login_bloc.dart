// lib/features/auth/presentation/controllers/login_bloc.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/services/local/usecases/set_remember_me_usecase.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_session_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/google_auth_params.dart';
import 'package:routex_mobile/features/auth/domain/entities/vehicle_type.dart';
import 'package:routex_mobile/features/auth/domain/usecases/get_google_id_token_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/login_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

/// Orchestrates the single login screen's state (Single Responsibility).
///
/// Translates raw UI submissions into use-case calls and exposes
/// the resulting [LoginStatus] without leaking any business rules into
/// the widget tree.
///
/// "Remember me" contract: [LoginState.rememberMe] is purely transient UI
/// state — it is never read from storage, so the checkbox is always unchecked
/// when the screen opens, and toggling it writes nothing. The decision is
/// persisted through [setRememberMeUseCase] only after a login actually
/// succeeds, and a failed attempt persists nothing at all.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required this.loginUseCase,
    required this.googleSignInUseCase,
    required this.getGoogleIdTokenUseCase,
    required this.setRememberMeUseCase,
  }) : super(LoginState.initial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginErrorDismissed>(_onErrorDismissed);
    on<LoginRememberMeToggled>(_onRememberMeToggled);
    on<LoginGoogleSignInRequested>(_onGoogleSignInRequested);
    on<LoginGoogleFirstAttemptRequested>(_onGoogleFirstAttemptRequested);
    on<LoginGoogleVehicleSubmitted>(_onGoogleVehicleSubmitted);
    on<LoginGoogleVehicleDismissed>(_onGoogleVehicleDismissed);
  }

  /// Authenticates the submitted credentials and returns a session.
  final LoginUseCase loginUseCase;

  /// Exchanges a Google ID token for a session — with the vehicle details when
  /// the attempt carries them (`POST /auth/google`).
  final GoogleSignInUseCase googleSignInUseCase;

  /// Runs the Google SDK once and yields its ID token.
  final GetGoogleIdTokenUseCase getGoogleIdTokenUseCase;

  /// Persists the "remember me" decision — called on a successful login only.
  final SetRememberMeUseCase setRememberMeUseCase;

  /// The Google ID token for the attempt currently in progress.
  ///
  /// Held in a private field of the bloc, never in [LoginState]: state is
  /// routinely rendered, copied and logged by the widget layer, and this value
  /// must exist in exactly one place in memory. It is dropped the moment the
  /// attempt ends — success, failure, or the user leaving the vehicle step.
  String? _pendingGoogleIdToken;

  /// Authenticates the user and, on success, records the "remember me" choice.
  ///
  /// The repository has already stored the tokens by the time the result comes
  /// back, so persisting the flag here keeps the two in sync: the flag can never
  /// outlive the session it refers to. On failure nothing is written.
  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));

    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {},
    );

    if (result.isRight()) {
      final session =
          result.getOrElse(() => throw StateError('unreachable'));
      // Persist the checkbox decision now that a session really exists, then
      // announce the success so the UI navigates away.
      await setRememberMeUseCase(
        SetRememberMeParams(value: state.rememberMe),
      );
      emit(state.copyWith(status: LoginStatus.success, session: session));
    }
  }

  /// Updates the checkbox in the bloc state only — no storage write.
  ///
  /// Persisting here would let an abandoned login attempt (the user checks the
  /// box, then kills the app) silently bypass the login screen on next launch.
  void _onRememberMeToggled(
    LoginRememberMeToggled event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(rememberMe: event.value));
  }

  /// Clears a previous failure so the UI can return to its idle state.
  void _onErrorDismissed(LoginErrorDismissed event, Emitter<LoginState> emit) {
    if (state.status == LoginStatus.failure) {
      emit(
        state.copyWith(status: LoginStatus.initial, clearErrorMessage: true),
      );
    }
  }

  /// Step 1 of Google sign-in: run the SDK once and hand the token to the
  /// first backend attempt.
  ///
  /// No request is made here — the exchange belongs to
  /// [LoginGoogleFirstAttemptRequested], fired from this handler once the token
  /// exists, so the two handlers mirror the two attempts the flow makes and the
  /// token still never leaves the bloc.
  ///
  /// The state stays `loading` from the first tap: the vehicle step must not
  /// appear before the backend has said the account is new, so there is no
  /// window in which the sheet flashes for a returning user.
  Future<void> _onGoogleSignInRequested(
    LoginGoogleSignInRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading, clearErrorMessage: true));

    final result = await getGoogleIdTokenUseCase();

    if (result.isCancelled) {
      // The user dismissed the chooser: back to idle, and deliberately no
      // error message — nothing went wrong.
      emit(state.copyWith(status: LoginStatus.initial));
      return;
    }

    final failure = result.failure;
    if (failure != null) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: failure.message,
        ),
      );
      return;
    }

    // Kept in this bloc only, never in [LoginState] and never in a route.
    _pendingGoogleIdToken = result.idToken;

    // Queued rather than awaited so the attempt gets a handler of its own. The
    // guard keeps a screen torn down while the chooser was open (the bloc is
    // already closed) from throwing on the way out.
    if (!isClosed) add(const LoginGoogleFirstAttemptRequested());
  }

  /// Step 2 of Google sign-in: `POST /auth/google` with the token alone.
  ///
  /// This is the attempt that tells the two kinds of Google user apart, so its
  /// three outcomes are deliberately different:
  ///
  /// * a session — the account already exists, so it is persisted like any
  ///   other login and the vehicle step is never shown;
  /// * [GoogleVehicleRequiredFailure] — the account is brand-new, so the token
  ///   is kept for the vehicle step and [LoginStatus.awaitingVehicle] opens it;
  /// * anything else — the attempt is over: the token is dropped and the
  ///   mapped message is shown, with no sheet.
  Future<void> _onGoogleFirstAttemptRequested(
    LoginGoogleFirstAttemptRequested event,
    Emitter<LoginState> emit,
  ) async {
    final token = _pendingGoogleIdToken;
    if (token == null) {
      // The attempt was abandoned before this event ran (the bloc was rebuilt
      // mid-flow). Return to idle rather than leaving the loading overlay up
      // for a request that is no longer pending.
      emit(state.copyWith(status: LoginStatus.initial));
      return;
    }

    final result = await googleSignInUseCase(GoogleAuthParams(idToken: token));

    final failure = result.fold((failure) => failure, (_) => null);
    if (failure == null) {
      _pendingGoogleIdToken = null;
      await _completeGoogleLogin(result, emit);
      return;
    }

    if (failure is GoogleVehicleRequiredFailure) {
      // The backend has flagged this identity as new: the token stays pending
      // for the vehicle step, which is the only place it is spent.
      emit(state.copyWith(status: LoginStatus.awaitingVehicle));
      return;
    }

    _pendingGoogleIdToken = null;
    emit(
      state.copyWith(
        status: LoginStatus.failure,
        errorMessage: failure.message,
      ),
    );
  }

  /// Step 3 of Google sign-in: call `POST /auth/google` with the token and the
  /// vehicle details the user just supplied — the attempt that registers the
  /// brand-new account step 2 identified.
  ///
  /// The token is cleared before the request is made, so a failure cannot leave
  /// a live credential behind: retrying always starts from the chooser again,
  /// which is the only way to obtain a fresh token.
  ///
  /// TODO(fcmToken): the endpoint accepts an `fcmToken` field for push
  /// registration, but the backend contract for whether it is required is
  /// unknown, so it is not sent here. Adding it needs `Firebase.initializeApp()`
  /// (and therefore `FirebaseMessaging`) to run before any use case is built,
  /// which is out of scope for the Google flow — the login screen must keep
  /// working without Firebase. Confirm the contract, then add the token here
  /// only.
  Future<void> _onGoogleVehicleSubmitted(
    LoginGoogleVehicleSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final token = _pendingGoogleIdToken;
    if (token == null) {
      // The vehicle step cannot outlive the token that opened it (e.g. the bloc
      // was rebuilt mid-flow). Treat it as an abandoned attempt rather than
      // firing a request that is certain to be rejected.
      emit(state.copyWith(status: LoginStatus.initial));
      return;
    }

    final vehicleNumber = event.vehicleNumber.trim();
    if (vehicleNumber.isEmpty) {
      // Belt and braces: the vehicle form already validates this, so reaching
      // here means a caller bypassed the UI. No request is made.
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'errVehicleRequired',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading, clearErrorMessage: true));

    final result = await googleSignInUseCase(
      GoogleAuthParams(
        idToken: token,
        vehicleType: event.vehicleType,
        vehicleNumber: vehicleNumber,
      ),
    );

    _pendingGoogleIdToken = null;

    final failure = result.fold((failure) => failure, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: failure.message,
        ),
      );
      return;
    }

    await _completeGoogleLogin(result, emit);
  }

  /// Persists the "remember me" decision and announces the Google session.
  ///
  /// Shared by both Google attempts so the ordering contract is written once:
  /// the repository has already stored the tokens by the time the result comes
  /// back, so the flag is written before the success is announced and can never
  /// outlive the session it refers to.
  Future<void> _completeGoogleLogin(
    Either<Failure, AuthSessionEntity> result,
    Emitter<LoginState> emit,
  ) async {
    final session = result.getOrElse(() => throw StateError('unreachable'));
    await setRememberMeUseCase(SetRememberMeParams(value: state.rememberMe));
    emit(state.copyWith(status: LoginStatus.success, session: session));
  }

  /// Handles the user backing out of the vehicle step.
  ///
  /// Drops the token and returns to idle without an error: nothing failed, the
  /// user simply chose not to finish. Showing a message here would be noise.
  void _onGoogleVehicleDismissed(
    LoginGoogleVehicleDismissed event,
    Emitter<LoginState> emit,
  ) {
    _pendingGoogleIdToken = null;
    emit(state.copyWith(status: LoginStatus.initial, clearErrorMessage: true));
  }

  @override
  Future<void> close() {
    // Never leave a credential in memory after the screen is gone.
    _pendingGoogleIdToken = null;
    return super.close();
  }
}
