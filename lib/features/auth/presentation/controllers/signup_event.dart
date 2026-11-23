// lib/features/auth/presentation/controllers/signup_event.dart
part of 'signup_bloc.dart';

/// Base class for all signup-related events.
abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the user requests a profile photo (from camera or gallery).
class SignupProfileImageRequested extends SignupEvent {
  const SignupProfileImageRequested({required this.isCamera});
  final bool isCamera;

  @override
  List<Object?> get props => [isCamera];
}

/// Fired when the user taps "Continue" on Step 1 with valid form data.
class SignupStep1Submitted extends SignupEvent {
  const SignupStep1Submitted({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.phoneCountryIsoCode,
  });
  final String firstName;
  final String lastName;
  final String email;

  /// National phone number as typed, e.g. `0599114453`. Normalized to E.164 by
  /// the use case, which needs the country to do it correctly.
  final String phone;

  /// ISO 3166-1 alpha-2 code of the country chosen in the dial-code picker.
  final String phoneCountryIsoCode;

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phone,
    phoneCountryIsoCode,
  ];
}

/// Fired when the user taps "Create account" on Step 2 with a valid password.
///
/// This is the final action of the flow: the password is validated, folded
/// into the accumulated registration and submitted to the backend in one go.
class SignupStep2Submitted extends SignupEvent {
  const SignupStep2Submitted({required this.password});
  final String password;

  @override
  List<Object?> get props => [password];
}

/// Fired when the user taps "Use a different email" on the OTP screen.
///
/// The bloc only counts the request (see [SignupState.profileEditRequestId]);
/// the flow shell reacts by returning to Step 1, where the address can be
/// corrected and the flow re-submitted. A counter rather than a sticky flag is
/// used so a screen that is rebuilt later can tell an old request from a new
/// one.
class SignupEditProfileRequested extends SignupEvent {
  const SignupEditProfileRequested();
}

/// Fired when the user navigates back from Step 2 to Step 1.
///
/// Reverts [SignupStatus] from [SignupStatus.step1Complete] back to
/// [SignupStatus.initial] so the [BlocListener] in [SignupFlowPage] does not
/// re-trigger a forward navigation when the state is inspected again, and wipes
/// the stored password so it is re-entered rather than inherited.
class SignupBackToStep1Requested extends SignupEvent {
  const SignupBackToStep1Requested();
}
