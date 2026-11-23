// lib/features/route_fleet/domain/repositories/route_fleet_repository.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import '../entities/fleet_company.dart';
import '../entities/fleet_info.dart';
import '../entities/location_report.dart';

abstract class RouteFleetRepository {
  Future<FleetInfo> getActiveRoute();
  Future<FleetInfo> updateStopStatus(String stopId, bool isCompleted);
  Future<FleetInfo> reorderStopToLast(int stopIndex);
  Future<void> reportWrongLocation(LocationReport report);

  Future<Either<Failure, List<FleetCompany>>> searchFleets(String query);
  Future<Either<Failure, String?>> joinFleet(String companyId);
  Future<Either<Failure, String?>> joinFleetByCode(String code);
}
