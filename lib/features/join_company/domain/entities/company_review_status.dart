import 'package:equatable/equatable.dart';
import 'company.dart';

enum CompanyReviewStep {
  requestSent,
  companyReview,

  /// J13: the company approved the request.
  approved,

  /// J12: the company turned the request down.
  declined,
}

/// Status of the driver's request to join a company.
class CompanyReviewStatus extends Equatable {
  const CompanyReviewStatus({
    required this.company,
    required this.currentStep,
    required this.sentTimeFormatted,
    required this.driverName,
    this.isCheckingForUpdates = false,
    this.companyDetails,
    this.sentDateLabel,
    this.reviewedDateLabel,
    this.declineReason,
    this.vehicleTitle,
    this.vehicleDetails,
  });

  final Company company;
  final CompanyReviewStep currentStep;
  final String sentTimeFormatted;
  final String driverName;
  final bool isCheckingForUpdates;

  /// `Jeddah • Last-mile delivery` (J12).
  final String? companyDetails;

  /// `8 Oct • 10:42` (J12).
  final String? sentDateLabel;

  /// `10 Oct • 14:05` (J12).
  final String? reviewedDateLabel;

  /// What the company wrote when it declined (J12).
  final String? declineReason;

  /// The vehicle the company set for the driver, `Toyota Hiace · Van` (J13).
  final String? vehicleTitle;

  /// `Plate PAL-99488 · White` (J13).
  final String? vehicleDetails;

  CompanyReviewStatus copyWith({
    Company? company,
    CompanyReviewStep? currentStep,
    String? sentTimeFormatted,
    String? driverName,
    bool? isCheckingForUpdates,
    String? companyDetails,
    String? sentDateLabel,
    String? reviewedDateLabel,
    String? declineReason,
    String? vehicleTitle,
    String? vehicleDetails,
  }) {
    return CompanyReviewStatus(
      company: company ?? this.company,
      currentStep: currentStep ?? this.currentStep,
      sentTimeFormatted: sentTimeFormatted ?? this.sentTimeFormatted,
      driverName: driverName ?? this.driverName,
      isCheckingForUpdates: isCheckingForUpdates ?? this.isCheckingForUpdates,
      companyDetails: companyDetails ?? this.companyDetails,
      sentDateLabel: sentDateLabel ?? this.sentDateLabel,
      reviewedDateLabel: reviewedDateLabel ?? this.reviewedDateLabel,
      declineReason: declineReason ?? this.declineReason,
      vehicleTitle: vehicleTitle ?? this.vehicleTitle,
      vehicleDetails: vehicleDetails ?? this.vehicleDetails,
    );
  }

  @override
  List<Object?> get props => [
        company,
        currentStep,
        sentTimeFormatted,
        driverName,
        isCheckingForUpdates,
        companyDetails,
        sentDateLabel,
        reviewedDateLabel,
        declineReason,
        vehicleTitle,
        vehicleDetails,
      ];
}
