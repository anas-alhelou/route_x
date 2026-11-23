// test/features/route_fleet/presentation/widgets/trip_sheet_planning_test.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/route_fleet/domain/entities/route_stop.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/route_planning_ready_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const stops = [
    RouteStop(id: 's1', title: 'Omar Haddad', address: 'Sari St, Al Zahra', eta: '10:05', isCompleted: false, status: 'Pending'),
    RouteStop(id: 's2', title: 'Lina Fares', address: 'Tahlia St, Al Nahda', eta: '10:24', isCompleted: false, status: 'Pending'),
    RouteStop(id: 's3', title: 'Ahmed Ali', address: 'Prince Sultan St, Al Rawdah', eta: '10:41', isCompleted: false, status: 'Pending'),
  ];

  Widget wrap(bool isReady) => ScreenUtilInit(
        designSize: const Size(412, 917),
        builder: (context, child) => MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: TripSheet(isReady: isReady, stops: stops, onStartRoute: () {}),
            ),
          ),
        ),
      );

  testWidgets('R02 planning: title, subtitle, spinner row, hidden times and calculating slider', (tester) async {
    await tester.pumpWidget(wrap(false));

    expect(find.text('Planning your route'), findsOneWidget);
    expect(find.text('Finding the fastest order for your 3 stops.'), findsOneWidget);
    expect(find.text('Getting your route ready'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Times are replaced by skeletons while planning.
    expect(find.text('10:05'), findsNothing);
    expect(find.text('10:24'), findsNothing);
    expect(find.text('Slide to start route'), findsNothing);
    expect(find.text('Route #3'), findsNothing);
  });

  testWidgets('R03 ready: title, times and slide label', (tester) async {
    await tester.pumpWidget(wrap(true));

    expect(find.text('Your route is ready'), findsOneWidget);
    expect(find.text('10:05'), findsOneWidget);
    expect(find.text('10:41'), findsOneWidget);
    expect(find.text('Slide to start route'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
