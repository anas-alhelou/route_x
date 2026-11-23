// test/features/route_fleet/presentation/widgets/return_handback_widgets_test.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/return_trip_card.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/hand_back_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ReturnTripCard renders dynamic depot and package data', (tester) async {
    bool atDepotTapped = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ReturnTripCard(
              depotName: 'Red Sea Express hub',
              metaText: 'Al Rawdah · 3.1 km · arrive 11:02',
              packageCountText: '1 package to hand back',
              packageSubtitle: 'Lina Fares · #RX-1036',
              onAtDepotTapped: () => atDepotTapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('RETURNING TO DEPOT'), findsOneWidget);
    expect(find.text('Red Sea Express hub'), findsOneWidget);
    expect(find.text('Al Rawdah · 3.1 km · arrive 11:02'), findsOneWidget);
    expect(find.text('1 package to hand back'), findsOneWidget);
    expect(find.text('Lina Fares · #RX-1036'), findsOneWidget);
    expect(find.text("I'm at the depot"), findsOneWidget);

    await tester.tap(find.text("I'm at the depot"));
    expect(atDepotTapped, isTrue);
  });

  testWidgets('ReturnTripCard renders 2+ failed packages correctly', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ReturnTripCard(
              depotName: 'Red Sea Express hub',
              metaText: 'Al Rawdah · 3.1 km · arrive 11:02',
              packageCountText: '2 packages to hand back',
              packageSubtitle: 'Lina Fares · #RX-1040, Ahmed Ali · #RX-1041',
              onAtDepotTapped: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('2 packages to hand back'), findsOneWidget);
    expect(find.text('Lina Fares · #RX-1040, Ahmed Ali · #RX-1041'), findsOneWidget);
  });

  testWidgets('HandBackSheet renders dynamic package checklist and enables button when checked', (tester) async {
    bool returnedTapped = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: HandBackSheet(
              packageCount: 1,
              customerName: 'Lina Fares',
              orderId: '#RX-1036',
              failureReason: 'Customer not answering',
              onReturnedTapped: () => returnedTapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('AT THE DEPOT'), findsOneWidget);
    expect(find.text('Hand back 1 package'), findsOneWidget);
    expect(find.text('Lina Fares · #RX-1036'), findsOneWidget);
    expect(find.text('Customer not answering'), findsOneWidget);
    expect(find.text('Returned · end my day'), findsOneWidget);

    await tester.tap(find.text('Returned · end my day'));
    expect(returnedTapped, isTrue);
  });
}
