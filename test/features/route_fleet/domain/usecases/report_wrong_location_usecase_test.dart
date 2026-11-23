// test/features/route_fleet/domain/usecases/report_wrong_location_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routex_mobile/features/route_fleet/domain/entities/location_report.dart';
import 'package:routex_mobile/features/route_fleet/domain/repositories/route_fleet_repository.dart';
import 'package:routex_mobile/features/route_fleet/domain/usecases/report_wrong_location_usecase.dart';

class MockRouteFleetRepository extends Mock implements RouteFleetRepository {}

void main() {
  late MockRouteFleetRepository mockRepository;
  late ReportWrongLocationUseCase useCase;

  setUp(() {
    mockRepository = MockRouteFleetRepository();
    useCase = ReportWrongLocationUseCase(mockRepository);
    registerFallbackValue(const LocationReport(stopId: '1', reasonCode: 'test', reasonText: 'test'));
  });

  test('ReportWrongLocationUseCase calls repository reportWrongLocation', () async {
    const report = LocationReport(
      stopId: 'stop-1',
      reasonCode: 'entrance_elsewhere',
      reasonText: 'Entrance is somewhere else',
      correctedLatLng: LatLng(21.5, 39.1),
    );

    when(() => mockRepository.reportWrongLocation(any())).thenAnswer((_) async {});

    await useCase(report);

    verify(() => mockRepository.reportWrongLocation(report)).called(1);
  });
}
