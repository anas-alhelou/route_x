import 'package:equatable/equatable.dart';
import '../../domain/entities/company.dart';
import '../../domain/entities/company_review_status.dart';

enum JoinCompanyStep {
  /// J01 / J02 / J03: Enter company code screen
  enterCode,

  /// J04: Confirm company screen
  confirmCompany,

  /// J10 / J10b: Under review screen
  underReview,
}

enum CodeValidationError {
  none,

  /// J02: We couldn't find a company with this code. Check it and try again.
  invalidCode,

  /// J03: This code is turned off. Ask your company for a new one.
  codeDisabled,
}

class JoinCompanyState extends Equatable {
  const JoinCompanyState({
    this.currentStep = JoinCompanyStep.enterCode,
    this.code = '',
    this.validationError = CodeValidationError.none,
    this.isLoading = false,
    this.isCheckingForUpdates = false,
    this.verifiedCompany,
    this.reviewStatus,
    this.errorMessage,
  });

  /// The active screen/stage in the join flow.
  final JoinCompanyStep currentStep;

  /// The 6-character code entered so far.
  final String code;

  /// The specific error type when code verification fails.
  final CodeValidationError validationError;

  /// Whether an async operation (verification, sending request) is in flight.
  final bool isLoading;

  /// Whether the "Checking for updates..." state (J10b) is active.
  final bool isCheckingForUpdates;

  /// The company returned by code verification (shown on J04).
  final Company? verifiedCompany;

  /// The review status (shown on J10/J10b).
  final CompanyReviewStatus? reviewStatus;

  /// Optional generic error message.
  final String? errorMessage;

  bool get hasError => validationError != CodeValidationError.none;
  bool get isContinueEnabled => code.length == 6 && !isLoading;

  JoinCompanyState copyWith({
    JoinCompanyStep? currentStep,
    String? code,
    CodeValidationError? validationError,
    bool? isLoading,
    bool? isCheckingForUpdates,
    Company? verifiedCompany,
    CompanyReviewStatus? reviewStatus,
    String? errorMessage,
    bool clearError = false,
    bool clearVerifiedCompany = false,
    bool clearReviewStatus = false,
  }) {
    return JoinCompanyState(
      currentStep: currentStep ?? this.currentStep,
      code: code ?? this.code,
      validationError:
          clearError ? CodeValidationError.none : (validationError ?? this.validationError),
      isLoading: isLoading ?? this.isLoading,
      isCheckingForUpdates: isCheckingForUpdates ?? this.isCheckingForUpdates,
      verifiedCompany:
          clearVerifiedCompany ? null : (verifiedCompany ?? this.verifiedCompany),
      reviewStatus:
          clearReviewStatus ? null : (reviewStatus ?? this.reviewStatus),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        code,
        validationError,
        isLoading,
        isCheckingForUpdates,
        verifiedCompany,
        reviewStatus,
        errorMessage,
      ];
}
