import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import '../entities/company_review_status.dart';
import '../repositories/join_company_repository.dart';

class GetRequestStatusUseCase implements UseCase<CompanyReviewStatus, String> {
  const GetRequestStatusUseCase(this._repository);

  final JoinCompanyRepository _repository;

  @override
  Future<Either<Failure, CompanyReviewStatus>> call(String companyCode) {
    return _repository.getRequestStatus(companyCode);
  }
}
