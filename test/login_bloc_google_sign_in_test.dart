// test/login_bloc_google_sign_in_test.dart
//
// LoginBloc's Google branch: the SDK runs once (loading -> first attempt), the
// token-only attempt decides what kind of user this is — an existing account
// gets a session with no vehicle step, a brand-new one opens the sheet and
// only then registers, and any other failure ends the attempt without one. The
// dismissed chooser, the remember-me contract and the token staying inside the
// bloc are covered alongside.
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/services/local/app_preferences_service.dart';
import 'package:routex_mobile/core/services/local/usecases/set_remember_me_usecase.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_session_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/google_auth_params.dart';
import 'package:routex_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/user_role.dart';
import 'package:routex_mobile/features/auth/domain/entities/vehicle_type.dart';
import 'package:routex_mobile/features/auth/domain/repositories/login_repository.dart';
import 'package:routex_mobile/features/auth/domain/services/google_sign_in_service.dart';
import 'package:routex_mobile/features/auth/domain/usecases/get_google_id_token_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/login_bloc.dart';

class _MockLoginRepository extends Mock implements LoginRepository {}

class _MockAppPreferences extends Mock implements AppPreferencesService {}

const _sdkToken = 'id-token-from-the-sdk';
const _vehicleNumber = 'ABC-1234';

void main() {
  late _MockLoginRepository repository;
  late _MockAppPreferences preferences;
  late _FakeGoogleSignInService google;

  setUpAll(() {
    // mocktail needs a valid instance to type-check the `any()` argument used
    // when stubbing repository.googleSignIn.
    registerFallbackValue(_params);
  });

  setUp(() {
    repository = _MockLoginRepository();
    preferences = _MockAppPreferences();
    google = _FakeGoogleSignInService();
    when(() => preferences.setRememberMe(any())).thenAnswer((_) async => true);
  });

  LoginBloc buildBloc() => LoginBloc(
    loginUseCase: LoginUseCase(repository: repository),
    googleSignInUseCase: GoogleSignInUseCase(repository: repository),
    getGoogleIdTokenUseCase: GetGoogleIdTokenUseCase(service: google),
    setRememberMeUseCase: SetRememberMeUseCase(
      preferencesService: preferences,
    ),
  );

  /// Stubs the two attempts the flow makes: [first] answers the token-only
  /// call, [second] (defaulting to [first]) every call after it — which is the
  /// one carrying the vehicle details.
  void stubGoogle({
    required Either<Failure, AuthSessionEntity> first,
    Either<Failure, AuthSessionEntity>? second,
  }) {
    var calls = 0;
    when(() => repository.googleSignIn(any())).thenAnswer((_) async {
      calls++;
      return calls == 1 ? first : (second ?? first);
    });
  }

  /// The account already exists: the first attempt alone is enough.
  Either<Failure, AuthSessionEntity> existingAccount() => Right(_session);

  /// The account is new: the vehicle step has to run before one is created.
  Either<Failure, AuthSessionEntity> newAccount() =>
      const Left(GoogleVehicleRequiredFailure());

  /// Captures every `GoogleAuthParams` the flow sent, in order.
  List<GoogleAuthParams> capturedParams() => verify(
    () => repository.googleSignIn(captureAny()),
  ).captured.cast<GoogleAuthParams>().toList();

  /// Runs both steps the way the UI does: the SDK, then the vehicle.
  Future<void> signInAndSubmit(LoginBloc bloc) async {
    bloc.add(const LoginGoogleSignInRequested());
    await bloc.stream.firstWhere(
      (state) => state.status == LoginStatus.awaitingVehicle,
    );
    bloc.add(
      const LoginGoogleVehicleSubmitted(
        vehicleType: VehicleType.car,
        vehicleNumber: _vehicleNumber,
      ),
    );
  }

  blocTest<LoginBloc, LoginState>(
    'an existing Google account signs in with no vehicle step',
    setUp: () => stubGoogle(first: existingAccount()),
    build: buildBloc,
    act: (bloc) => bloc.add(const LoginGoogleSignInRequested()),
    expect: () => [
      isA<LoginState>().having((s) => s.status, 'status', LoginStatus.loading),
      isA<LoginState>()
          .having((s) => s.status, 'status', LoginStatus.success)
          .having((s) => s.session?.user.id, 'session user id', 'usr_01'),
    ],
    verify: (_) {
      // The sheet is driven by LoginStatus.awaitingVehicle, which this path
      // never reaches — that absence is the whole point of the first attempt.
      expect(google.signInCalls, 1);

      final sent = capturedParams();
      expect(sent, hasLength(1));
      expect(sent.single.idToken, _sdkToken);
      expect(sent.single.platform, 'MOBILE');
      expect(
        sent.single.vehicleType,
        isNull,
        reason: 'an existing account must not be asked for a vehicle again',
      );
      expect(sent.single.vehicleNumber, isNull);
      verify(() => preferences.setRememberMe(false)).called(1);
    },
  );

  blocTest<LoginBloc, LoginState>(
    'a brand-new Google account opens the vehicle step, then succeeds',
    setUp: () => stubGoogle(first: newAccount(), second: existingAccount()),
    build: buildBloc,
    act: signInAndSubmit,
    skip: 2,
    expect: () => [
      isA<LoginState>().having((s) => s.status, 'status', LoginStatus.loading),
      isA<LoginState>()
          .having((s) => s.status, 'status', LoginStatus.success)
          .having((s) => s.session?.user.id, 'session user id', 'usr_01'),
    ],
    verify: (_) {
      final sent = capturedParams();
      expect(sent, hasLength(2));
      expect(sent.first.vehicleType, isNull, reason: 'attempt 1 is token only');
      expect(sent.first.vehicleNumber, isNull);
      expect(sent[1].vehicleType, VehicleType.car);
      expect(sent[1].vehicleNumber, _vehicleNumber);
      expect(sent.every((params) => params.idToken == _sdkToken), isTrue);
      expect(
        google.signInCalls,
        1,
        reason: 'the account chooser must never be shown twice for one attempt',
      );
      verify(() => preferences.setRememberMe(false)).called(1);
    },
  );

  blocTest<LoginBloc, LoginState>(
    'a network error on the first attempt fails without a vehicle sheet',
    setUp: () => stubGoogle(first: const Left(NetworkFailure())),
    build: buildBloc,
    act: (bloc) => bloc.add(const LoginGoogleSignInRequested()),
    expect: () => [
      isA<LoginState>().having((s) => s.status, 'status', LoginStatus.loading),
      isA<LoginState>()
          .having((s) => s.status, 'status', LoginStatus.failure)
          .having((s) => s.errorMessage, 'errorMessage', 'errNoInternetConnection'),
    ],
    verify: (_) {
      // No awaitingVehicle between loading and failure: a transport problem
      // says nothing about the account, so the sheet must stay closed.
      verify(() => repository.googleSignIn(any())).called(1);
      verifyNever(() => preferences.setRememberMe(any()));
    },
  );

  blocTest<LoginBloc, LoginState>(
    'a rejected token goes loading -> failure with the Google copy',
    setUp: () => stubGoogle(first: const Left(GoogleAuthTokenRejectedFailure())),
    build: buildBloc,
    act: (bloc) => bloc.add(const LoginGoogleSignInRequested()),
    expect: () => [
      isA<LoginState>().having((s) => s.status, 'status', LoginStatus.loading),
      isA<LoginState>()
          .having((s) => s.status, 'status', LoginStatus.failure)
          .having((s) => s.errorMessage, 'errorMessage', 'errGoogleAuthFailed'),
    ],
    verify: (_) {
      verifyNever(() => preferences.setRememberMe(any()));
    },
  );

  blocTest<LoginBloc, LoginState>(
    'a rejected vehicle step goes loading -> failure with the Google copy',
    // The second attempt is the one that registers the account, so a refusal
    // there is reported exactly like any other Google failure.
    setUp: () =>
        stubGoogle(first: newAccount(), second: const Left(GoogleAuthTokenRejectedFailure())),
    build: buildBloc,
    act: signInAndSubmit,
    skip: 3,
    expect: () => [
      isA<LoginState>()
          .having((s) => s.status, 'status', LoginStatus.failure)
          .having((s) => s.errorMessage, 'errorMessage', 'errGoogleAuthFailed'),
    ],
    verify: (_) {
      verifyNever(() => preferences.setRememberMe(any()));
    },
  );

  blocTest<LoginBloc, LoginState>(
    'a dismissed chooser returns to initial with no error message',
    setUp: () => google.result = const GoogleAuthResult.cancelled(),
    build: buildBloc,
    act: (bloc) => bloc.add(const LoginGoogleSignInRequested()),
    expect: () => [
      isA<LoginState>().having((s) => s.status, 'status', LoginStatus.loading),
      isA<LoginState>()
          .having((s) => s.status, 'status', LoginStatus.initial)
          .having((s) => s.errorMessage, 'errorMessage', isNull),
    ],
    verify: (_) {
      verifyNever(() => repository.googleSignIn(any()));
      verifyNever(() => preferences.setRememberMe(any()));
    },
  );

  blocTest<LoginBloc, LoginState>(
    'an SDK failure goes loading -> failure and shows the mapped message',
    setUp: () => google.result = const GoogleAuthResult.failure(
      GoogleAuthConfigurationFailure(),
    ),
    build: buildBloc,
    act: (bloc) => bloc.add(const LoginGoogleSignInRequested()),
    expect: () => [
      isA<LoginState>().having((s) => s.status, 'status', LoginStatus.loading),
      isA<LoginState>()
          .having((s) => s.status, 'status', LoginStatus.failure)
          .having(
            (s) => s.errorMessage,
            'errorMessage',
            'errGoogleNotConfigured',
          ),
    ],
    verify: (_) {
      verifyNever(() => repository.googleSignIn(any()));
      verifyNever(() => preferences.setRememberMe(any()));
    },
  );

  blocTest<LoginBloc, LoginState>(
    'the vehicle step cannot be submitted without a pending token',
    // The token is dropped when the user backs out, so a later submit must not
    // fire a request that is certain to be rejected.
    setUp: () => stubGoogle(first: existingAccount()),
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const LoginGoogleVehicleDismissed());
      await bloc.stream.firstWhere((s) => s.status == LoginStatus.initial);
      bloc.add(
        const LoginGoogleVehicleSubmitted(
          vehicleType: VehicleType.car,
          vehicleNumber: _vehicleNumber,
        ),
      );
    },
    verify: (_) {
      verifyNever(() => repository.googleSignIn(any()));
    },
  );

  blocTest<LoginBloc, LoginState>(
    'dismissing the vehicle step clears the token it was holding',
    setUp: () => stubGoogle(first: newAccount(), second: existingAccount()),
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const LoginGoogleSignInRequested());
      await bloc.stream.firstWhere(
        (state) => state.status == LoginStatus.awaitingVehicle,
      );
      bloc.add(const LoginGoogleVehicleDismissed());
      await bloc.stream.firstWhere((s) => s.status == LoginStatus.initial);
      // A submit after the dismissal has nothing left to send: the token the
      // vehicle step depended on is gone.
      bloc.add(
        const LoginGoogleVehicleSubmitted(
          vehicleType: VehicleType.car,
          vehicleNumber: _vehicleNumber,
        ),
      );
    },
    skip: 2,
    expect: () => [
      isA<LoginState>()
          .having((s) => s.status, 'status', LoginStatus.initial)
          .having((s) => s.errorMessage, 'errorMessage', isNull),
    ],
    verify: (_) {
      expect(
        capturedParams(),
        hasLength(1),
        reason: 'only the token-only attempt ran; the dismissal dropped the token',
      );
      verifyNever(() => preferences.setRememberMe(any()));
    },
  );

  blocTest<LoginBloc, LoginState>(
    'dismissing after a failure returns to idle and fires no second request',
    // The UI ends a rejected vehicle step with LoginGoogleVehicleDismissed so
    // the page is not left on a failure it has already reported: the error must
    // be cleared and the discarded token must not be reusable.
    setUp: () =>
        stubGoogle(first: newAccount(), second: const Left(GoogleAuthTokenRejectedFailure())),
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const LoginGoogleSignInRequested());
      await bloc.stream.firstWhere(
        (state) => state.status == LoginStatus.awaitingVehicle,
      );
      bloc.add(
        const LoginGoogleVehicleSubmitted(
          vehicleType: VehicleType.car,
          vehicleNumber: _vehicleNumber,
        ),
      );
      await bloc.stream.firstWhere((s) => s.status == LoginStatus.failure);
      bloc.add(const LoginGoogleVehicleDismissed());
    },
    skip: 4,
    expect: () => [
      isA<LoginState>()
          .having((s) => s.status, 'status', LoginStatus.initial)
          .having((s) => s.errorMessage, 'errorMessage', isNull),
    ],
    verify: (_) {
      verify(() => repository.googleSignIn(any())).called(2);
    },
  );

  blocTest<LoginBloc, LoginState>(
    'retrying after a failure starts from the chooser again',
    setUp: () => stubGoogle(
      first: const Left(NetworkFailure()),
      second: existingAccount(),
    ),
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const LoginGoogleSignInRequested());
      await bloc.stream.firstWhere((s) => s.status == LoginStatus.failure);
      bloc.add(const LoginErrorDismissed());
      bloc.add(const LoginGoogleSignInRequested());
      await bloc.stream.firstWhere((s) => s.status == LoginStatus.success);
    },
    verify: (_) {
      expect(
        google.signInCalls,
        2,
        reason: 'each retry is a fresh tap, so each runs the SDK once',
      );
      expect(
        capturedParams(),
        hasLength(2),
        reason: 'the retried attempt reaches the backend again',
      );
    },
  );

  group('remember me matches the email/password path', () {
    blocTest<LoginBloc, LoginState>(
      'a checked box is persisted once a Google session exists',
      setUp: () => stubGoogle(first: newAccount(), second: existingAccount()),
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const LoginRememberMeToggled(value: true));
        await signInAndSubmit(bloc);
      },
      verify: (_) {
        verify(() => preferences.setRememberMe(true)).called(1);
      },
    );

    blocTest<LoginBloc, LoginState>(
      'an unchecked box is persisted as false, not skipped',
      setUp: () => stubGoogle(first: newAccount(), second: existingAccount()),
      build: buildBloc,
      act: signInAndSubmit,
      verify: (_) {
        verify(() => preferences.setRememberMe(false)).called(1);
      },
    );
  });
}

const _params = GoogleAuthParams(
  idToken: _sdkToken,
  vehicleType: VehicleType.car,
  vehicleNumber: _vehicleNumber,
);

/// Stands in for the SDK: the tests script what one chooser produced.
class _FakeGoogleSignInService implements GoogleSignInService {
  GoogleAuthResult result = const GoogleAuthResult.success(_sdkToken);
  int signInCalls = 0;

  @override
  Future<GoogleAuthResult> signIn() async {
    signInCalls++;
    return result;
  }

  @override
  Future<void> signOut() async {}
}

final _session = AuthSessionEntity(
  user: const UserEntity(
    id: 'usr_01',
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com',
    role: UserRole.driver,
  ),
  tokens: const AuthTokensEntity(
    accessToken: 'access.jwt',
    refreshToken: 'refresh.jwt',
  ),
);
