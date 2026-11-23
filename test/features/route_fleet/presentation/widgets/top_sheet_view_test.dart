// test/features/route_fleet/presentation/widgets/top_sheet_view_test.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_state.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/top_sheet_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final sheet in [DrivingModalSheet.locationStopped, DrivingModalSheet.backFromMaps]) {
    testWidgets('TopSheetView ${sheet.name} lays out without overflow', (tester) async {
      tester.view.physicalSize = const Size(412, 917);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(412, 917),
          builder: (context, child) => MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: TopSheetView(
                  sheetType: sheet,
                  customerName: 'Omar Haddad',
                  companyName: 'Red Sea Express',
                  onTurnOnTapped: () {},
                  onIveArrivedTapped: () {},
                  onResumeTapped: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Figma height is ~191 (24 + 77 + 12 + 52 + 24 + border); the test font is wider than
      // Satoshi so only "no overflow" is asserted here.
      expect(tester.takeException(), isNull);
      expect(find.byType(TopSheetView), findsOneWidget);
    });
  }
}
