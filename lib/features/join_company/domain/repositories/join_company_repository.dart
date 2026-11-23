import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import '../entities/company.dart';
import '../entities/company_review_status.dart';

abstract class JoinCompanyRepository {
  /// Verifies a 6-character company code.
  ///
  /// Returns [Company] on success, [InvalidCompanyCodeFailure] for unknown codes,
  /// or [CompanyCodeDisabledFailure] for disabled codes.
  Future<Either<Failure, Company>> verifyCompanyCode(String code);

  /// Submits the driver's request to join the company.
  Future<Either<Failure, CompanyReviewStatus>> sendCompanyRequest(String companyCode);

  /// Checks the current review status of the driver's request.
  Future<Either<Failure, CompanyReviewStatus>> getRequestStatus(String companyCode);

  /// Cancels a pending join request.
  Future<Either<Failure, void>> cancelCompanyRequest(String companyCode);
}
