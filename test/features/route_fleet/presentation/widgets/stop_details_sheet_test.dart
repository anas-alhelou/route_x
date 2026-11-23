// test/features/route_fleet/presentation/widgets/stop_details_sheet_test.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/stop_details_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('StopDetailsSheet renders with full data', (tester) async {
    bool backTapped = false;
    bool callTapped = false;
    bool messageTapped = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StopDetailsSheet(
              stopNumber: 1,
              totalStops: 3,
              customerName: 'Omar Haddad',
              metaText: 'Sari St, Al Zahra · #RX-1039 · 1.1 km',
              gateCode: '4417#',
              timeWindow: '10:00 – 10:30',
              packagesText: '2 · drop-off',
              companyNote: 'Call when you arrive. Building 12, 3rd floor.',
              phone: '+966501234567',
              onCallTapped: () => callTapped = true,
              onMessageTapped: () => messageTapped = true,
              onBackToMapTapped: () => backTapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('NEXT STOP · 1 OF 3'), findsOneWidget);
    expect(find.text('Omar Haddad'), findsOneWidget);
    expect(find.text('4417#'), findsOneWidget);
    expect(find.text('10:00 – 10:30'), findsOneWidget);
    expect(find.text('2 · drop-off'), findsOneWidget);
    expect(find.text('Call when you arrive. Building 12, 3rd floor.'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
    expect(find.text('Back to map'), findsOneWidget);

    await tester.tap(find.text('Back to map'));
    expect(backTapped, isTrue);

    await tester.tap(find.text('Call'));
    expect(callTapped, isTrue);

    await tester.tap(find.text('Message'));
    expect(messageTapped, isTrue);
  });

  testWidgets('StopDetailsSheet renders with no optional data (hides optional rows and phone buttons)', (tester) async {
    bool backTapped = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StopDetailsSheet(
              stopNumber: 2,
              totalStops: 3,
              customerName: 'Ahmed Ali',
              metaText: 'Prince Sultan St · #RX-1041 · 2.0 km',
              gateCode: null,
              timeWindow: null,
              packagesText: null,
              companyNote: null,
              phone: null,
              onBackToMapTapped: () => backTapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('NEXT STOP · 2 OF 3'), findsOneWidget);
    expect(find.text('Ahmed Ali'), findsOneWidget);
    expect(find.text('Back to map'), findsOneWidget);

    // Optional fields and phone buttons should be hidden
    expect(find.text('Gate code'), findsNothing);
    expect(find.text('Time window'), findsNothing);
    expect(find.text('Call'), findsNothing);
    expect(find.text('Message'), findsNothing);

    await tester.tap(find.text('Back to map'));
    expect(backTapped, isTrue);
  });
}
