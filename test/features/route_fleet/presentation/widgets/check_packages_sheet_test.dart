// test/features/route_fleet/presentation/widgets/check_packages_sheet_test.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/route_fleet/domain/entities/fleet_info.dart';
import 'package:routex_mobile/features/route_fleet/domain/entities/route_stop.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/check_packages_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testFleet = FleetInfo(
    routeId: 'rt-1',
    routeName: 'Route 1',
    activeVehicleNumber: 'VAN-1',
    totalDistance: '5 km',
    progressPercentage: 0.0,
    depotInfo: DepotInfo(
      name: 'Hub',
      address: 'Addr',
      distanceText: '1 km',
      etaText: '10:00',
    ),
    stops: [
      RouteStop(
        id: 'stop-1',
        title: 'Omar Haddad',
        address: 'Sari St',
        eta: '10:05',
        isCompleted: false,
        status: 'Pending',
        orderId: '#RX-1034',
        packageType: 'Medium box',
      ),
      RouteStop(
        id: 'stop-2',
        title: 'Lina Fares',
        address: 'Tahlia St',
        eta: '10:24',
        isCompleted: false,
        status: 'Pending',
        orderId: '#RX-1035',
        packageType: 'Small envelope',
      ),
    ],
  );

  testWidgets('CheckPackagesSheet renders packages and shows disabled button when not all checked', (tester) async {
    final checkedIds = <String>{'stop-1'};
    bool startRouteTapped = false;
    bool packageMissingTapped = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CheckPackagesSheet(
              fleetInfo: testFleet,
              checkedStopIds: checkedIds,
              onPackageToggled: (_) {},
              onStartRouteTapped: () => startRouteTapped = true,
              onPackageMissingTapped: () => packageMissingTapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('BEFORE YOU GO'), findsOneWidget);
    expect(find.text('Are all 2 packages in the van?'), findsOneWidget);
    expect(find.text('Omar Haddad'), findsOneWidget);
    expect(find.text('Lina Fares'), findsOneWidget);
    expect(find.text('1 of 2 checked'), findsOneWidget);
    expect(find.text('A package is missing'), findsOneWidget);

    // Button is disabled when not all checked
    await tester.tap(find.text('1 of 2 checked'));
    expect(startRouteTapped, isFalse);

    await tester.tap(find.text('A package is missing'));
    expect(packageMissingTapped, isTrue);
  });

  testWidgets('CheckPackagesSheet shows Start route button when all checked', (tester) async {
    final checkedIds = <String>{'stop-1', 'stop-2'};
    bool startRouteTapped = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CheckPackagesSheet(
              fleetInfo: testFleet,
              checkedStopIds: checkedIds,
              onPackageToggled: (_) {},
              onStartRouteTapped: () => startRouteTapped = true,
              onPackageMissingTapped: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Start route'), findsOneWidget);
    expect(find.text('A package is missing'), findsNothing);

    await tester.tap(find.text('Start route'));
    expect(startRouteTapped, isTrue);
  });
}
