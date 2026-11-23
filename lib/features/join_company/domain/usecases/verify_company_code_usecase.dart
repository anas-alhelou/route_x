import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import '../entities/company.dart';
import '../repositories/join_company_repository.dart';

class VerifyCompanyCodeUseCase implements UseCase<Company, String> {
  const VerifyCompanyCodeUseCase(this._repository);

  final JoinCompanyRepository _repository;

  @override
  Future<Either<Failure, Company>> call(String code) {
    return _repository.verifyCompanyCode(code);
  }
}
