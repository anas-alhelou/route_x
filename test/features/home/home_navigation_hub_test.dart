// test/features/home/home_navigation_hub_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/bloc/language/language_bloc.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/home/presentation/pages/home_navigation_hub_page.dart';

Widget _buildHubTestScope({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return BlocProvider<LanguageBloc>(
    create: (_) => LanguageBloc(),
    child: MediaQuery(
      data: const MediaQueryData(size: Size(412, 917)),
      child: ScreenUtilInit(
        designSize: const Size(412, 917),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      ),
    ),
  );
}

Future<void> _pumpHub(
  WidgetTester tester, {
  required Widget child,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(412, 917);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    _buildHubTestScope(child: child, locale: locale),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeNavigationHubPage Tests', () {
    testWidgets('renders header, search bar, categories and scenario targets',
        (tester) async {
      await _pumpHub(tester, child: const HomeNavigationHubPage());

      // Header branding & title
      expect(find.text('RouteX · Navigator'), findsOneWidget);
      expect(find.text('Home Screens Navigator'), findsOneWidget);

      // Search bar
      expect(find.byType(TextField), findsOneWidget);

      // Category filter chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Delivery Scenarios'), findsOneWidget);

      // Verify top cards exist
      expect(find.text('HM1'), findsOneWidget);
    });

    testWidgets('filtering by Delivery Scenarios shows scenario cards',
        (tester) async {
      await _pumpHub(tester, child: const HomeNavigationHubPage());

      // Tap "Delivery Scenarios" chip
      await tester.tap(find.text('Delivery Scenarios'));
      await tester.pumpAndSettle();

      expect(find.text('HM1'), findsOneWidget);
      expect(find.text('N01'), findsNothing);
    });

    testWidgets('filtering by Notifications category shows only N01 and N02',
        (tester) async {
      await _pumpHub(tester, child: const HomeNavigationHubPage());

      // Scroll to Notifications chip and tap
      final notifFinder = find.text('Notifications');
      await tester.ensureVisible(notifFinder);
      await tester.tap(notifFinder);
      await tester.pumpAndSettle();

      // Should show N01 and N02
      expect(find.text('N01'), findsOneWidget);
      expect(find.text('N02'), findsOneWidget);

      // HM1 should be filtered out
      expect(find.text('HM1'), findsNothing);
    });

    testWidgets('searching for ready filters results to HM1 target',
        (tester) async {
      await _pumpHub(tester, child: const HomeNavigationHubPage());

      // Enter search query "ready"
      await tester.enterText(find.byType(TextField), 'ready');
      await tester.pumpAndSettle();

      expect(find.text('HM1'), findsOneWidget);
      expect(find.text('HM2'), findsNothing);
      expect(find.text('N01'), findsNothing);
    });

    testWidgets('renders properly in Arabic (RTL)', (tester) async {
      await _pumpHub(
        tester,
        child: const HomeNavigationHubPage(),
        locale: const Locale('ar'),
      );

      // Arabic header & category
      expect(find.text('متنقل شاشات الهوم'), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('سيناريوهات التوصيل'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}
