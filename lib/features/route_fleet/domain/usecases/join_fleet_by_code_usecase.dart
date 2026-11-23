import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import '../repositories/route_fleet_repository.dart';

class JoinFleetByCodeUseCase {
  const JoinFleetByCodeUseCase({required this.repository});

  final RouteFleetRepository repository;

  Future<Either<Failure, String?>> call(String code) {
    return repository.joinFleetByCode(code);
  }
}
