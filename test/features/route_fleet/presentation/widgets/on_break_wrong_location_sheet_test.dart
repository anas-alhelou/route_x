// test/features/route_fleet/presentation/widgets/on_break_wrong_location_sheet_test.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/on_break_sheet.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/wrong_location_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OnBreakSheet renders and triggers resume and add minutes', (tester) async {
    bool resumeTapped = false;
    bool addMinutesTapped = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: OnBreakSheet(
              breakStartTime: DateTime.now(),
              allowedMinutes: 15,
              onResumeTapped: () => resumeTapped = true,
              onAddMinutesTapped: () => addMinutesTapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('ON BREAK'), findsOneWidget);
    expect(find.text('Resume route'), findsOneWidget);
    expect(find.text('Add 5 minutes'), findsOneWidget);

    await tester.tap(find.text('Resume route'));
    expect(resumeTapped, isTrue);

    await tester.tap(find.text('Add 5 minutes'));
    expect(addMinutesTapped, isTrue);
  });

  testWidgets('WrongLocationSheet renders reasons and triggers send to dispatch', (tester) async {
    String? capturedCode;
    String? capturedText;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => MaterialApp(
 localizationsDelegates: AppLocalizations.localizationsDelegates,
 supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: WrongLocationSheet(
              customerName: 'Omar Haddad',
              onSendToDispatchTapped: (code, text) {
                capturedCode = code;
                capturedText = text;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text("What's wrong with the pin?"), findsOneWidget);
    expect(find.text('Entrance is somewhere else'), findsOneWidget);
    expect(find.text('Pin is on the wrong street'), findsOneWidget);

    await tester.tap(find.text('Pin is on the wrong street'));
    await tester.pump();

    await tester.tap(find.text('Send to dispatch'));
    expect(capturedCode, 'wrong_street');
    expect(capturedText, 'Pin is on the wrong street');
  });
}
