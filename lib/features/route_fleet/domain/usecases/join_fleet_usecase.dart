import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import '../repositories/route_fleet_repository.dart';

class JoinFleetUseCase {
  const JoinFleetUseCase({required this.repository});

  final RouteFleetRepository repository;

  Future<Either<Failure, String?>> call(String companyId) {
    return repository.joinFleet(companyId);
  }
}
