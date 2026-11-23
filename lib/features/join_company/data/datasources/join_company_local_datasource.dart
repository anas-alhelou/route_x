import 'dart:async';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import '../models/company_model.dart';
import '../models/company_review_status_model.dart';
import '../../domain/entities/company_review_status.dart';

class InvalidCompanyCodeException implements Exception {
  const InvalidCompanyCodeException();
}

class CompanyCodeDisabledException implements Exception {
  const CompanyCodeDisabledException();
}

abstract class JoinCompanyLocalDataSource {
  Future<CompanyModel> verifyCode(String code);
  Future<CompanyReviewStatusModel> sendRequest(String companyCode);
  Future<CompanyReviewStatusModel> getStatus(String companyCode);
  Future<void> cancelRequest(String companyCode);
}

class JoinCompanyLocalDataSourceImpl implements JoinCompanyLocalDataSource {
  // Known mock companies
  static const Map<String, CompanyModel> _knownCompanies = {
    'RSX482': CompanyModel(
      id: 'c_rsx482',
      name: 'Red Sea Express',
      code: 'RSX482',
      logoAsset: AppAssets.imgFleetRedSeaExpress,
      isActive: true,
    ),
    'KTW210': CompanyModel(
      id: 'c_ktw210',
      name: 'KTN Wears',
      code: 'KTW210',
      logoAsset: AppAssets.imgFleetKtnWears,
      isActive: false, // Turned off
    ),
  };

  CompanyReviewStatusModel? _currentPendingRequest;

  @override
  Future<CompanyModel> verifyCode(String rawCode) async {
    // Artificial small delay to simulate clean async data source
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final normalized = rawCode.trim().toUpperCase();

    // 1. Explicit invalid code: RSX481 -> J02
    if (normalized == 'RSX481') {
      throw const InvalidCompanyCodeException();
    }

    // 2. Explicit turned off / disabled code: KTW210 -> J03
    if (normalized == 'KTW210') {
      throw const CompanyCodeDisabledException();
    }

    // 3. Known valid code RSX482
    if (_knownCompanies.containsKey(normalized)) {
      final company = _knownCompanies[normalized]!;
      if (!company.isActive) {
        throw const CompanyCodeDisabledException();
      }
      return company;
    }

    // 4. Any other valid 6-character alphanumeric code defaults to Red Sea Express or a mock company
    if (normalized.length == 6 && RegExp(r'^[A-Z0-9]{6}$').hasMatch(normalized)) {
      return CompanyModel(
        id: 'c_${normalized.toLowerCase()}',
        name: 'Red Sea Express',
        code: normalized,
        logoAsset: AppAssets.imgFleetRedSeaExpress,
        isActive: true,
      );
    }

    // Otherwise invalid
    throw const InvalidCompanyCodeException();
  }

  @override
  Future<CompanyReviewStatusModel> sendRequest(String companyCode) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final normalized = companyCode.trim().toUpperCase();
    final company = _knownCompanies[normalized] ??
        CompanyModel(
          id: 'c_${normalized.toLowerCase()}',
          name: 'Red Sea Express',
          code: normalized,
          logoAsset: AppAssets.imgFleetRedSeaExpress,
          isActive: true,
        );

    final status = CompanyReviewStatusModel(
      company: company,
      currentStep: CompanyReviewStep.companyReview,
      sentTimeFormatted: 'Today, 10:24 AM',
      driverName: 'Hamza Barakat',
      isCheckingForUpdates: false,
    );

    _currentPendingRequest = status;
    return status;
  }

  /// The company answers the first time the driver checks (J10b -> J13), or
  /// turns the request down for [_declinedCode] (J10b -> J12).
  static const String _declinedCode = 'RSX483';

  @override
  Future<CompanyReviewStatusModel> getStatus(String companyCode) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final pending = _currentPendingRequest;
    if (pending != null) {
      final answered = _answer(pending);
      _currentPendingRequest = answered;
      return answered;
    }
    // Default mock status if loaded directly
    final normalized = companyCode.trim().toUpperCase();
    return CompanyReviewStatusModel(
      company: CompanyModel(
        id: 'c_${normalized.toLowerCase()}',
        name: 'Red Sea Express',
        code: normalized.isEmpty ? 'RSX482' : normalized,
        logoAsset: AppAssets.imgFleetRedSeaExpress,
        isActive: true,
      ),
      currentStep: CompanyReviewStep.companyReview,
      sentTimeFormatted: 'Today, 10:24 AM',
      driverName: 'Hamza Barakat',
      isCheckingForUpdates: false,
    );
  }

  CompanyReviewStatusModel _answer(CompanyReviewStatusModel pending) {
    if (pending.currentStep == CompanyReviewStep.approved ||
        pending.currentStep == CompanyReviewStep.declined) {
      return pending;
    }
    final declined = pending.company.code.toUpperCase() == _declinedCode;
    return CompanyReviewStatusModel(
      company: pending.company,
      currentStep:
          declined ? CompanyReviewStep.declined : CompanyReviewStep.approved,
      sentTimeFormatted: pending.sentTimeFormatted,
      driverName: pending.driverName,
      companyDetails: 'Jeddah • Last-mile delivery',
      sentDateLabel: '8 Oct • 10:42',
      reviewedDateLabel: '10 Oct • 14:05',
      declineReason: declined
          ? '“We’re only taking drivers from our company. Sorry about that.”'
          : null,
      vehicleTitle: declined ? null : 'Toyota Hiace · Van',
      vehicleDetails: declined ? null : 'Plate PAL-99488 · White',
    );
  }

  @override
  Future<void> cancelRequest(String companyCode) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _currentPendingRequest = null;
  }
}
