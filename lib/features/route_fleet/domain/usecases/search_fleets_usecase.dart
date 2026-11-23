import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import '../entities/fleet_company.dart';
import '../repositories/route_fleet_repository.dart';

class SearchFleetsUseCase {
  const SearchFleetsUseCase({required this.repository});

  final RouteFleetRepository repository;

  Future<Either<Failure, List<FleetCompany>>> call(String query) {
    return repository.searchFleets(query);
  }
}
