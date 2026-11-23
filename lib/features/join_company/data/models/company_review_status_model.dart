import '../../domain/entities/company_review_status.dart';
import 'company_model.dart';

class CompanyReviewStatusModel extends CompanyReviewStatus {
  const CompanyReviewStatusModel({
    required super.company,
    required super.currentStep,
    required super.sentTimeFormatted,
    required super.driverName,
    super.isCheckingForUpdates = false,
    super.companyDetails,
    super.sentDateLabel,
    super.reviewedDateLabel,
    super.declineReason,
    super.vehicleTitle,
    super.vehicleDetails,
  });

  factory CompanyReviewStatusModel.fromJson(Map<String, dynamic> json) {
    return CompanyReviewStatusModel(
      company: CompanyModel.fromJson(json['company'] as Map<String, dynamic>),
      currentStep: _parseStep(json['currentStep'] as String?),
      sentTimeFormatted: json['sentTimeFormatted'] as String? ?? 'Today, 10:24 AM',
      driverName: json['driverName'] as String? ?? 'Hamza Barakat',
      isCheckingForUpdates: json['isCheckingForUpdates'] as bool? ?? false,
      companyDetails: json['companyDetails'] as String?,
      sentDateLabel: json['sentDateLabel'] as String?,
      reviewedDateLabel: json['reviewedDateLabel'] as String?,
      declineReason: json['declineReason'] as String?,
      vehicleTitle: json['vehicleTitle'] as String?,
      vehicleDetails: json['vehicleDetails'] as String?,
    );
  }

  static CompanyReviewStep _parseStep(String? step) {
    switch (step) {
      case 'requestSent':
        return CompanyReviewStep.requestSent;
      case 'approved':
        return CompanyReviewStep.approved;
      case 'declined':
        return CompanyReviewStep.declined;
      case 'companyReview':
      default:
        return CompanyReviewStep.companyReview;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'company': CompanyModel.fromEntity(company).toJson(),
      'currentStep': currentStep.name,
      'sentTimeFormatted': sentTimeFormatted,
      'driverName': driverName,
      'isCheckingForUpdates': isCheckingForUpdates,
      'companyDetails': companyDetails,
      'sentDateLabel': sentDateLabel,
      'reviewedDateLabel': reviewedDateLabel,
      'declineReason': declineReason,
      'vehicleTitle': vehicleTitle,
      'vehicleDetails': vehicleDetails,
    };
  }

  factory CompanyReviewStatusModel.fromEntity(CompanyReviewStatus entity) {
    return CompanyReviewStatusModel(
      company: entity.company,
      currentStep: entity.currentStep,
      sentTimeFormatted: entity.sentTimeFormatted,
      driverName: entity.driverName,
      isCheckingForUpdates: entity.isCheckingForUpdates,
      companyDetails: entity.companyDetails,
      sentDateLabel: entity.sentDateLabel,
      reviewedDateLabel: entity.reviewedDateLabel,
      declineReason: entity.declineReason,
      vehicleTitle: entity.vehicleTitle,
      vehicleDetails: entity.vehicleDetails,
    );
  }
}
