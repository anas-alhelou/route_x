// test/features/route_fleet/presentation/widgets/state_banner_test.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_state.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/state_banner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const cases = {
    StateBannerType.rerouting: 'Finding a new way',
    StateBannerType.weakGps: 'Weak GPS signal',
    StateBannerType.offline: "You're offline",
  };

  for (final entry in cases.entries) {
    testWidgets('StateBanner ${entry.key.name} renders without overflow', (tester) async {
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
                child: StateBanner(type: entry.key, customerName: 'Omar Haddad'),
              ),
            ),
          ),
        ),
      );

      expect(find.text(entry.value), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('StateBanner offline uses the Figma R25 text', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(412, 917),
        builder: (context, child) => MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StateBanner(type: StateBannerType.offline, customerName: 'Omar Haddad'),
          ),
        ),
      ),
    );

    expect(find.textContaining('1 update is saved and will send'), findsOneWidget);
  });
}
