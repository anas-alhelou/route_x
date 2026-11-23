import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routex_mobile/features/route_fleet/domain/entities/fleet_info.dart';
import 'package:routex_mobile/features/route_fleet/domain/repositories/route_fleet_repository.dart';
import 'package:routex_mobile/features/route_fleet/domain/usecases/reorder_stop_usecase.dart';

class MockRouteFleetRepository extends Mock implements RouteFleetRepository {}

void main() {
  late ReorderStopUseCase useCase;
  late MockRouteFleetRepository mockRepository;

  setUp(() {
    mockRepository = MockRouteFleetRepository();
    useCase = ReorderStopUseCase(mockRepository);
  });

  test('should reorder stop to last via repository', () async {
    const tFleetInfo = FleetInfo(
      routeId: 'rt-1',
      routeName: 'Route 1',
      activeVehicleNumber: 'RX-1',
      totalDistance: '5 km',
      progressPercentage: 0.0,
      depotInfo: DepotInfo(
        name: 'Red Sea Express hub',
        address: 'Al Rawdah',
        distanceText: '3.1 km',
        etaText: 'arrive 11:02',
      ),
      stops: [],
    );

    when(() => mockRepository.reorderStopToLast(1)).thenAnswer((_) async => tFleetInfo);

    final result = await useCase(1);

    expect(result, tFleetInfo);
    verify(() => mockRepository.reorderStopToLast(1)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
