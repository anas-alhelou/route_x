// lib/features/auth/presentation/controllers/signup_state.dart
part of 'signup_bloc.dart';

/// Represents the current status of the multi-step signup flow.
enum SignupStatus {
  /// Initial state, no interaction yet.
  initial,

  /// Step 1 has been validated and saved â€” UI should navigate to Step 2.
  step1Complete,

  /// The registration request completed successfully â€” UI should navigate
  /// to the OTP verification screen.
  registered,

  /// A loading / async operation is in progress.
  loading,

  /// An error occurred (e.g. server-side validation).
  failure,
}

/// Immutable state held by [SignupBloc] across both signup steps.
class SignupState extends Equatable {
  const SignupState({
    this.status = SignupStatus.initial,
    this.profileImage,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.phoneCountryIsoCode = '',
    this.phoneCountryDialCode = '',
    this.countryName = '',
    this.password = '',
    this.currentStep = 1,
    this.errorMessage,
    this.profileEditRequestId = 0,
  });

  /// The last submitted status; drives navigation and loading UI.
  final SignupStatus status;

  /// Optional photo chosen by the user.
  final File? profileImage;

  /// First name captured in step 1.
  final String firstName;

  /// Last name captured in step 1.
  final String lastName;

  /// Email captured in step 1; also used by the OTP verification route.
  final String email;

  /// Phone number captured in step 1, in E.164 format.
  final String phone;

  /// ISO 3166-1 alpha-2 code of the country picked for [phone], e.g. `PS`.
  ///
  /// Needed to restore the dialing-code picker and to re-validate the number
  /// whenever the flow returns to step 1.
  final String phoneCountryIsoCode;

  /// Dial code of that country, e.g. `+970`.
  final String phoneCountryDialCode;

  /// Non-localized English name of that country, sent as the API `country`.
  final String countryName;

  /// Password created in step 2. Populated only once the step is submitted.
  final String password;

  /// Which step the flow is currently on (1-indexed).
  final int currentStep;

  /// Non-null only when [status] is [SignupStatus.failure].
  final String? errorMessage;

  /// How many times [SignupEditProfileRequested] has been handled.
  ///
  /// Incremented instead of latched so the flow shell can act on each request
  /// exactly once â€” it compares this counter against the one it last handled â€”
  /// and so a screen rebuilt later can tell a request it already saw from a
  /// genuinely new one (raised by "Use a different email" on the OTP screen).
  final int profileEditRequestId;

  /// Convenience: default / reset state.
  factory SignupState.initial() => const SignupState();

  /// Returns a copy with only the provided fields replaced.
  SignupState copyWith({
    SignupStatus? status,
    File? profileImage,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? phoneCountryIsoCode,
    String? phoneCountryDialCode,
    String? countryName,
    String? password,
    int? currentStep,
    String? errorMessage,
    int? profileEditRequestId,
  }) {
    return SignupState(
      status: status ?? this.status,
      profileImage: profileImage ?? this.profileImage,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneCountryIsoCode: phoneCountryIsoCode ?? this.phoneCountryIsoCode,
      phoneCountryDialCode: phoneCountryDialCode ?? this.phoneCountryDialCode,
      countryName: countryName ?? this.countryName,
      password: password ?? this.password,
      currentStep: currentStep ?? this.currentStep,
      errorMessage: errorMessage ?? this.errorMessage,
      profileEditRequestId: profileEditRequestId ?? this.profileEditRequestId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profileImage?.path,
    firstName,
    lastName,
    email,
    phone,
    phoneCountryIsoCode,
    phoneCountryDialCode,
    countryName,
    password,
    currentStep,
    errorMessage,
    profileEditRequestId,
  ];
}
