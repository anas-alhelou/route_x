import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import '../repositories/join_company_repository.dart';

class CancelCompanyRequestUseCase implements UseCase<void, String> {
  const CancelCompanyRequestUseCase(this._repository);

  final JoinCompanyRepository _repository;

  @override
  Future<Either<Failure, void>> call(String companyCode) {
    return _repository.cancelCompanyRequest(companyCode);
  }
}
