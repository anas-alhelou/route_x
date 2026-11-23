// test/features/route_fleet/presentation/widgets/arrival_sheet_layout_test.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/arrival_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 392 is the emulator width where the overflow was seen; 412 is the Figma width.
  // (Narrower phones need a separate pass: text sizes (sp) do not scale with the .w boxes.)
  for (final width in [392.0, 412.0]) {
    testWidgets('ArrivalSheet (R12) lays out without overflow at width $width', (tester) async {
      tester.view.physicalSize = Size(width, 917);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(412, 917),
          builder: (context, child) => MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Center(
                child: ArrivalSheet(
                  stopIndexText: 'STOP 1 OF 3',
                  arrivalTime: '10:05',
                  customerName: 'Omar Haddad',
                  addressAndOrder: 'Sari St, Al Zahra · #RX-1039',
                  companyNote: 'Call when you arrive. Building 12, 3rd floor.',
                  onMapsTapped: () {},
                  onMoreTapped: () {},
                  onCouldntDeliverTapped: () {},
                  onDeliveredTapped: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Delivered'), findsOneWidget);
      expect(find.text("Couldn't deliver"), findsOneWidget);
      // Overflow errors are reported as exceptions and would fail the test.
      expect(tester.takeException(), isNull);
    });
  }
}
