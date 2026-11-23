// test/phone_country_field_test.dart
//
// Covers the country half of [RouteXPhoneField]: that the dial-code prefix
// shows the country it claims to show, and that changing the country repaints
// it. The bug these guard is a silent one — a picker that updates the
// controller but never rebuilds leaves a stale "+970" next to a number being
// typed for Saudi Arabia, and every validation error then looks like the
// user's mistake.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/widgets/routex_phone_field.dart';
import 'package:routex_mobile/features/auth/domain/entities/phone_country.dart';

void main() {
  testWidgets('falls back to the default country and shows its dial code', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const RouteXPhoneField()));
    await tester.pumpAndSettle();

    expect(find.text(kDefaultPhoneCountry.dialCode), findsOneWidget);
  });

  testWidgets('restores the stored country from initialCountryIsoCode', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const RouteXPhoneField(initialCountryIsoCode: 'SA')),
    );
    await tester.pumpAndSettle();

    final saudi = phoneCountryByIsoCode('SA')!;
    expect(find.text(saudi.dialCode), findsOneWidget);
    expect(find.text(kDefaultPhoneCountry.dialCode), findsNothing);
  });

  testWidgets('an unknown ISO code falls back instead of rendering nothing', (
    tester,
  ) async {
    // A record written before the country column existed, or a country the
    // app does not offer, must not leave the prefix blank.
    await tester.pumpWidget(
      _host(const RouteXPhoneField(initialCountryIsoCode: 'ZZ')),
    );
    await tester.pumpAndSettle();

    expect(find.text(kDefaultPhoneCountry.dialCode), findsOneWidget);
  });

  testWidgets('picking a country in the sheet repaints the prefix', (
    tester,
  ) async {
    // No controller from the parent: the field owns a private one, so this is
    // the path where the field has to listen to its own controller.
    await tester.pumpWidget(_host(const RouteXPhoneField()));
    await tester.pumpAndSettle();

    await tester.tap(find.text(kDefaultPhoneCountry.dialCode));
    await tester.pumpAndSettle();

    // The sheet's list is lazy, so the country is filtered into view instead of
    // scrolling for it. Searching the dial code keeps the test independent of
    // the localized country name.
    final jordan = phoneCountryByIsoCode('JO')!;
    await tester.enterText(find.byType(TextField).last, jordan.dialCode);
    await tester.pumpAndSettle();

    // Scoped to the list: the search box itself now contains the dial code too.
    await tester.tap(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text(jordan.dialCode),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(jordan.dialCode), findsOneWidget);
    expect(
      find.text(kDefaultPhoneCountry.dialCode),
      findsNothing,
      reason: 'the prefix still shows the old dial code after the pick',
    );
  });

  testWidgets('a parent changing the controller repaints the prefix', (
    tester,
  ) async {
    final controller = RouteXPhoneFieldController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _host(RouteXPhoneField(countryController: controller)),
    );
    await tester.pumpAndSettle();

    final qatar = phoneCountryByIsoCode('QA')!;
    controller.selectCountry(qatar);
    await tester.pumpAndSettle();

    expect(find.text(qatar.dialCode), findsOneWidget);
    expect(find.text(kDefaultPhoneCountry.dialCode), findsNothing);
  });

  testWidgets(
    'an external controller keeps its own selection across rebuilds',
    (tester) async {
      final controller = RouteXPhoneFieldController(
        initialCountry: phoneCountryByIsoCode('BH'),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _host(RouteXPhoneField(countryController: controller)),
      );
      await tester.pumpAndSettle();
      expect(find.text('+973'), findsOneWidget);

      // A rebuild that does not change the controller must not reset the user's
      // pick back to the default.
      await tester.pumpWidget(
        _host(
          RouteXPhoneField(countryController: controller, hintText: 'changed'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('+973'), findsOneWidget);
    },
  );
}

/// Wraps [child] in the localization and sizing the field's flag images and
/// country labels depend on.
Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(400, 800),
  minTextAdapt: true,
  builder: (context, _) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  ),
);
