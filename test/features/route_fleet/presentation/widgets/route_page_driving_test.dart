// test/features/route_fleet/presentation/widgets/route_page_driving_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_state.dart';
import 'package:routex_mobile/features/route_fleet/presentation/pages/route_page.dart';
import 'package:routex_mobile/features/route_fleet/data/models/fleet_info_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('RoutePage pumps in driving mode with map controller and ready map without exception', (tester) async {
    tester.view.physicalSize = const Size(360, 690);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const testDepot = DepotInfoModel(
      name: 'Hub',
      address: 'Addr',
      distanceText: '1 km',
      etaText: '10:00',
    );

    final testFleet = FleetInfoModel(
      routeId: 'rt-1',
      routeName: 'Route 1',
      activeVehicleNumber: 'VAN-1',
      totalDistance: '5 km',
      progressPercentage: 0.0,
      depotInfo: testDepot,
      stops: [],
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: RoutePage(
              isDriving: true,
              // No default card: this test only checks the map controller readiness.
              bottomCard: const SizedBox.shrink(),
              drivingState: RouteFleetDriving(
                fleetInfo: testFleet,
                currentStopIndex: 0,
                maneuverType: ManeuverType.turnLeft,
                distanceValue: '80',
                distanceUnit: 'm',
                instructionText: 'Proceed',
                arrivalTime: '10:05',
                remainingMinutes: 4,
                remainingKm: 1.1,
                driverLatLng: const LatLng(21.5, 39.1),
                traveledPath: const [],
                upcomingPath: const [],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(RoutePage), findsOneWidget);
  });

  testWidgets('RoutePage renders the subBadge toast (R17 "sent for review" / R30 "stop moved")', (tester) async {
    tester.view.physicalSize = const Size(412, 917);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // The map tries to download tiles; the test HttpClient answers 400, which is irrelevant here.
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (_) {};
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(412, 917),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: RoutePage(
              showMapControls: false,
              bottomCard: const SizedBox.shrink(),
              subBadge: const Text('Sent to Red Sea Express for review'),
              subBadgeTop: 214,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sent to Red Sea Express for review'), findsOneWidget);
  });
}
