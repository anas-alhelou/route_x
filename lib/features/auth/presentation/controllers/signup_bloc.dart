// lib/features/auth/presentation/controllers/signup_bloc.dart
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/network/exception_mapper.dart';
import 'package:routex_mobile/features/auth/domain/entities/phone_country.dart';
import 'package:routex_mobile/features/auth/domain/entities/register_params.dart';
import 'package:routex_mobile/features/auth/domain/entities/user_role.dart';
import 'package:routex_mobile/features/auth/domain/usecases/pick_profile_image_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/validate_signup_step1_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/validate_signup_step3_usecase.dart';

part 'signup_event.dart';
part 'signup_state.dart';

/// Manages the shared state across the entire two-step sign-up flow.
///
/// Provide this Bloc above the first signup screen and keep it alive for the
/// duration of the flow (e.g., via a feature-level `BlocProvider` in the
/// route builder or inside [MultiBlocProvider] in main.dart).
class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc({
    required this.validateStep1UseCase,
    required this.pickProfileImageUseCase,
    required this.validateStep3UseCase,
    required this.registerUseCase,
  }) : super(SignupState.initial()) {
    on<SignupProfileImageRequested>(_onProfileImageRequested);
    on<SignupStep1Submitted>(_onStep1Submitted);
    on<SignupStep2Submitted>(_onStep2Submitted);
    on<SignupEditProfileRequested>(_onEditProfileRequested);
    on<SignupBackToStep1Requested>(_onBackToStep1Requested);
  }

  final ValidateSignupStep1UseCase validateStep1UseCase;
  final PickProfileImageUseCase pickProfileImageUseCase;
  final ValidateSignupStep3UseCase validateStep3UseCase;

  /// Submits the finished registration to the backend.
  final RegisterUseCase registerUseCase;

  /// The email whose `POST /auth/register` ran out of time.
  ///
  /// The server may well have created the account (and sent the code) while the
  /// app was still waiting - on a cold Render instance that is the usual case.
  /// The retry then comes back "already exists" even though this very user
  /// created it a moment ago, so that one answer is treated as success and the
  /// flow carries on to the code screen, where Resend is available.
  String? _timedOutEmail;

  // â”€â”€ Handlers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _onProfileImageRequested(
    SignupProfileImageRequested event,
    Emitter<SignupState> emit,
  ) async {
    final file = await pickProfileImageUseCase(isCamera: event.isCamera);
    if (file != null) {
      emit(state.copyWith(profileImage: file));
    }
  }

  Future<void> _onStep1Submitted(
    SignupStep1Submitted event,
    Emitter<SignupState> emit,
  ) async {
    emit(state.copyWith(status: SignupStatus.loading));

    final params = ValidateSignupStep1Params(
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      phone: event.phone,
      phoneCountryIsoCode: event.phoneCountryIsoCode,
    );

    final result = await validateStep1UseCase(params);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: SignupStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (credentials) {
        emit(
          state.copyWith(
            firstName: credentials.firstName,
            lastName: credentials.lastName,
            email: credentials.email,
            phone: credentials.phone,
            phoneCountryIsoCode: credentials.phoneCountryIsoCode,
            phoneCountryDialCode: credentials.phoneCountryDialCode,
            countryName: credentials.countryName,
            currentStep: 2,
            status: SignupStatus.step1Complete,
            errorMessage: null,
          ),
        );
      },
    );
  }

  /// Validates the password and, on success, submits the whole registration to
  /// the backend as a DRIVER.
  ///
  /// The password is the last thing the flow collects, so there is no separate
  /// review step: a valid password means the assembled account is complete.
  /// Vehicle details are not collected â€” the fleet assigns a vehicle after
  /// onboarding.
  Future<void> _onStep2Submitted(
    SignupStep2Submitted event,
    Emitter<SignupState> emit,
  ) async {
    emit(state.copyWith(status: SignupStatus.loading, errorMessage: null));

    final validation = await validateStep3UseCase(
      ValidateSignupStep3Params(password: event.password),
    );

    String? validationError;
    var password = '';
    validation.fold(
      (failure) => validationError = failure.message,
      (valid) => password = valid,
    );
    if (validationError != null) {
      emit(
        state.copyWith(
          status: SignupStatus.failure,
          errorMessage: validationError,
        ),
      );
      return;
    }

    final params = RegisterParams(
      firstName: state.firstName,
      lastName: state.lastName,
      email: state.email,
      phone: state.phone,
      phoneCountryIsoCode: state.phoneCountryIsoCode,
      password: password,
      role: UserRole.driver,
      // The non-localized English name of the country picked in the dialing-code
      // dropdown. Falls back to the app's default country so a state built
      // before this field existed still sends a valid value; see the
      // TODO(backend) on `RegisterParams.country` about the expected format.
      country: state.countryName.isNotEmpty
          ? state.countryName
          : kDefaultPhoneCountry.apiName,
    );

    final result = await registerUseCase(params);

    result.fold(
      (failure) {
        if (failure.message == ExceptionMapper.requestTimeoutKey) {
          _timedOutEmail = state.email;
        } else if (_timedOutEmail == state.email &&
            _isAlreadyRegistered(failure)) {
          _timedOutEmail = null;
          emit(state.copyWith(password: password, status: SignupStatus.registered));
          return;
        }
        emit(
          state.copyWith(
            status: SignupStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        _timedOutEmail = null;
        emit(
          state.copyWith(
            password: password,
            status: SignupStatus.registered,
          ),
        );
      },
    );
  }

  /// The backend's "user with this email or phone already exists" answer.
  ///
  /// Matched on the message because the backend gives no machine-readable code
  /// for it (see the backend requests).
  bool _isAlreadyRegistered(Failure failure) =>
      failure.message.toLowerCase().contains('already exist');

  /// Counts an [SignupEditProfileRequested] so the flow shell can return to
  /// Step 1 to correct the email. [status] is deliberately left alone: the flow
  /// shell reacts to the counter, not to a status change.
  void _onEditProfileRequested(
    SignupEditProfileRequested event,
    Emitter<SignupState> emit,
  ) {
    emit(state.copyWith(profileEditRequestId: state.profileEditRequestId + 1));
  }

  /// Reverts the state back to Step 1 so the forward [BlocListener] in
  /// [SignupFlowPage] does not accidentally re-navigate to Step 2.
  ///
  /// The stored [SignupState.password] is wiped as well: leaving a step
  /// backwards means the user re-enters that data rather than inherits it.
  void _onBackToStep1Requested(
    SignupBackToStep1Requested event,
    Emitter<SignupState> emit,
  ) {
    emit(
      state.copyWith(
        status: SignupStatus.initial,
        currentStep: 1,
        password: '',
      ),
    );
  }
}
