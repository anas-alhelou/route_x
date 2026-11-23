// lib/features/auth/presentation/controllers/login_state.dart
part of 'login_bloc.dart';

/// Status of the login operation.
enum LoginStatus {
  /// No interaction yet.
  initial,

  /// Awaiting the repository's authentication response.
  ///
  /// Only ever set while a request is genuinely in flight: every outcome
  /// (success, cancellation, failure) leaves it again, so the loading overlay
  /// and the disabled buttons can never get stuck.
  loading,

  /// The backend reported a brand-new Google account, so the vehicle step is
  /// on screen to collect what registering it needs.
  ///
  /// Not a loading state: no request is in progress while the user fills the
  /// form, and the buttons must stay tappable. Reached only from the specific
  /// vehicle-required answer — never from a generic failure — which is what
  /// keeps the sheet off the screen for an account that already exists.
  awaitingVehicle,

  /// Authentication succeeded â€” a session is available.
  success,

  /// Authentication failed â€” [errorMessage] is set.
  failure,
}

/// Immutable state held by [LoginBloc].
class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.session,
    this.rememberMe = false,
  });

  /// Current stage of the login operation.
  final LoginStatus status;

  /// Non-null only when [status] is [LoginStatus.failure].
  final String? errorMessage;

  /// Non-null only when [status] is [LoginStatus.success]. Carries the role
  /// needed to route the user to the correct home.
  final AuthSessionEntity? session;

  /// "Remember me" checkbox value — transient UI state only.
  ///
  /// It always starts as `false` (the checkbox is never pre-checked from a
  /// previous session) and is never written to storage while toggling. The
  /// value is persisted by [LoginBloc] after a *successful* login, and read
  /// back only by the cold-start flow to decide whether to skip the login
  /// screen.
  final bool rememberMe;

  /// Convenience: default / reset state.
  factory LoginState.initial() => const LoginState();

  /// Returns a copy with only the provided fields replaced. Use
  /// [clearErrorMessage] to explicitly null the error message.
  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    AuthSessionEntity? session,
    bool? rememberMe,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      session: session ?? this.session,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, session, rememberMe];
}
