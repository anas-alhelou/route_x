// lib/features/auth/presentation/controllers/login_event.dart
part of 'login_bloc.dart';

/// Base class for all login-related events.
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the user submits the login form with raw field values.
class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Fired when the user clears the previous failure so the UI can
/// return to its idle state (e.g. after editing a field).
class LoginErrorDismissed extends LoginEvent {
  const LoginErrorDismissed();

  @override
  List<Object?> get props => [];
}

/// Fired when the user toggles the "Remember me" checkbox on the login form.
class LoginRememberMeToggled extends LoginEvent {
  const LoginRememberMeToggled({required this.value});

  final bool value;

  @override
  List<Object?> get props => [value];
}

/// Fired when the user taps the Google Sign-In social button.
///
/// Runs the Google SDK only; the first backend attempt follows as a separate
/// event once the ID token exists.
class LoginGoogleSignInRequested extends LoginEvent {
  const LoginGoogleSignInRequested();

  @override
  List<Object?> get props => [];
}

/// Fired by the bloc itself once the SDK produced a token: the first
/// `POST /auth/google` attempt, carrying the identity alone.
///
/// Deliberately its own event (and never dispatched by the widget layer): it
/// is the attempt that asks the backend whether this Google account already
/// exists, so keeping it apart from [LoginGoogleVehicleSubmitted] is what
/// separates "sign in" from "register the vehicle" — and what keeps a
/// returning user from ever seeing the vehicle step.
class LoginGoogleFirstAttemptRequested extends LoginEvent {
  const LoginGoogleFirstAttemptRequested();

  @override
  List<Object?> get props => [];
}

/// Fired when the user completes the mandatory vehicle step of Google sign-in.
///
/// This is the second attempt: the backend has already reported the account as
/// new, and this event carries the details that register it. It carries the
/// collected details, never the ID token: that stays inside the bloc, so no
/// credential can travel through an event, a route or a log.
class LoginGoogleVehicleSubmitted extends LoginEvent {
  const LoginGoogleVehicleSubmitted({
    required this.vehicleType,
    required this.vehicleNumber,
  });

  /// The vehicle the user picked.
  final VehicleType vehicleType;

  /// The plate number the user typed; trimmed by the bloc.
  final String vehicleNumber;

  @override
  List<Object?> get props => [vehicleType, vehicleNumber];
}

/// Fired when the user dismisses the vehicle step (back gesture or close).
class LoginGoogleVehicleDismissed extends LoginEvent {
  const LoginGoogleVehicleDismissed();

  @override
  List<Object?> get props => [];
}
