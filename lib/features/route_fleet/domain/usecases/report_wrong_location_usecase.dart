// lib/features/route_fleet/domain/usecases/report_wrong_location_usecase.dart
import '../entities/location_report.dart';
import '../repositories/route_fleet_repository.dart';

class ReportWrongLocationUseCase {
  const ReportWrongLocationUseCase(this._repository);

  final RouteFleetRepository _repository;

  Future<void> call(LocationReport report) async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _repository.reportWrongLocation(report);
  }
}
