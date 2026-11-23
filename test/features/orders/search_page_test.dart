import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_detail_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_search_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/order_detail_repository_impl.dart';
import 'package:routex_mobile/features/orders/data/repositories/order_search_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_search_result_entity.dart';
import 'package:routex_mobile/features/orders/domain/entities/orders_today_entity.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_order_detail_usecase.dart';
import 'package:routex_mobile/features/orders/domain/usecases/search_orders_usecase.dart';
import 'package:routex_mobile/features/orders/presentation/pages/order_detail_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/search_page.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/order_detail/order_detail_cards.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/search/search_no_results.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/search/search_result_tile.dart';

const _designSize = Size(412, 917);

Future<void> _pumpApp(WidgetTester tester, Widget home) async {
  await tester.binding.setSurfaceSize(_designSize);
  tester.view.physicalSize = _designSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _designSize,
      builder: (context, child) => MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

List<String> _codes(List<OrderSearchResultEntity> results) =>
    [for (final r in results) r.orderCode];

void main() {
  group('matching', () {
    const source = OrderSearchLocalDataSourceImpl();

    test('a name finds every order for it, today first', () async {
      final results = await source.search('Ahmed', OrderSearchScope.all);
      expect(_codes(results), ['RX-1041', 'RX-1052', 'RX-1058']);
    });

    test('scope narrows without changing the query', () async {
      expect(
        _codes(await source.search('Ahmed', OrderSearchScope.today)),
        ['RX-1041'],
      );
      expect(
        _codes(await source.search('Ahmed', OrderSearchScope.upcoming)),
        ['RX-1052', 'RX-1058'],
      );
    });

    test('an order number matches with or without # and in any case',
        () async {
      expect(
        _codes(await source.search('#rx-1052', OrderSearchScope.all)),
        ['RX-1052'],
      );
    });

    test('a street matches even where the row shows only the district',
        () async {
      final results =
          await source.search('Prince Sultan', OrderSearchScope.upcoming);
      expect(_codes(results), ['RX-1052']);
    });

    test('four digits match the end of the phone, not the middle', () async {
      // Ahmed Ali's phone ends in 3344 — both his orders.
      expect(
        _codes(await source.search('3344', OrderSearchScope.all)),
        ['RX-1041', 'RX-1052'],
      );
      // 2223 sits in the middle of that number and must not match.
      expect(await source.search('2223', OrderSearchScope.all), isEmpty);
    });

    test('a blank query never reaches the repository', () async {
      const useCase = SearchOrdersUseCase(
        OrderSearchRepositoryImpl(localDataSource: source),
      );
      expect(await useCase('   ', OrderSearchScope.all), isEmpty);
    });
  });

  group('screen', () {
    setUp(() {
      getIt.registerLazySingleton<SearchOrdersUseCase>(
        () => const SearchOrdersUseCase(
          OrderSearchRepositoryImpl(
            localDataSource: OrderSearchLocalDataSourceImpl(),
          ),
        ),
      );
      getIt.registerLazySingleton<GetOrderDetailUseCase>(
        () => GetOrderDetailUseCase(
          const OrderDetailRepositoryImpl(
            localDataSource: OrderDetailLocalDataSourceImpl(),
          ),
        ),
      );
    });
    tearDown(() {
      getIt.unregister<SearchOrdersUseCase>();
      getIt.unregister<GetOrderDetailUseCase>();
    });

    testWidgets('matches the mockup for "Ahmed"', (tester) async {
      await _pumpApp(tester, const SearchPage(initialQuery: 'Ahmed'));

      expect(find.widgetWithText(TextField, 'Ahmed'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);

      expect(find.text('3 RESULTS'), findsOneWidget);
      expect(find.text('Ahmed Ali · #RX-1041'), findsOneWidget);
      expect(
        find.text('Today · Prince Sultan St, Al Rawdah'),
        findsOneWidget,
      );
      expect(find.text('Ahmed Ali · #RX-1052'), findsOneWidget);
      expect(find.text('Tomorrow · Al Rawdah'), findsOneWidget);
      expect(find.text('Ahmed Saleh · #RX-1058'), findsOneWidget);
      expect(find.text('Tue 13 Oct · Al Nahda'), findsOneWidget);

      // Only the order dispatch just added wears the pill.
      expect(find.byType(NewOrderPill), findsOneWidget);
      expect(find.text('New'), findsOneWidget);

      expect(find.textContaining('last 4 digits of the phone'), findsOneWidget);
    });

    testWidgets('a scope chip re-runs the same query', (tester) async {
      await _pumpApp(tester, const SearchPage(initialQuery: 'Ahmed'));

      await tester.tap(find.text('Today'));
      await tester.pump();
      await tester.pump();

      expect(find.text('1 RESULT'), findsOneWidget);
      expect(find.byType(SearchResultTile), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Ahmed'), findsOneWidget);
    });

    testWidgets('clearing the field drops back to the help text',
        (tester) async {
      await _pumpApp(tester, const SearchPage(initialQuery: 'Ahmed'));

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      await tester.pump();

      expect(find.byType(SearchResultTile), findsNothing);
      expect(find.textContaining('RESULT'), findsNothing);
      expect(find.textContaining('last 4 digits of the phone'), findsOneWidget);
    });

    testWidgets('a query with no matches shows the empty state',
        (tester) async {
      await _pumpApp(tester, const SearchPage());

      await tester.enterText(find.byType(TextField), 'Mansoor');
      await tester.pump();
      await tester.pump();

      expect(find.byType(SearchNoResults), findsOneWidget);
      expect(find.text('No orders match “Mansoor”'), findsOneWidget);
      expect(
        find.text('Check the spelling, or try a street name or order number. '
            'Finished orders are in History.'),
        findsOneWidget,
      );
      expect(find.text('Scan a package instead'), findsOneWidget);
      // The general help gives way to the specific advice above.
      expect(find.textContaining('last 4 digits of the phone'), findsNothing);
      expect(find.byType(SearchResultTile), findsNothing);
      expect(find.textContaining('RESULT'), findsNothing);
    });

    testWidgets('typing a match after a miss brings the list back',
        (tester) async {
      await _pumpApp(tester, const SearchPage(initialQuery: 'Mansoor'));
      expect(find.byType(SearchNoResults), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Ahmed');
      await tester.pump();
      await tester.pump();

      expect(find.byType(SearchNoResults), findsNothing);
      expect(find.text('3 RESULTS'), findsOneWidget);
    });

    testWidgets("a today result opens that stop's detail", (tester) async {
      await _pumpApp(tester, const SearchPage(initialQuery: 'Ahmed'));

      await tester.tap(find.text('Ahmed Ali · #RX-1041'));
      await tester.pumpAndSettle();

      expect(find.byType(OrderDetailView), findsOneWidget);
      expect(find.text('#RX-1041'), findsOneWidget);
    });

    testWidgets('the ETA pill opens search on the customer, Cancel returns',
        (tester) async {
      const ahmed = TodayStopEntity(
        id: 'ORD-10032',
        sequence: 4,
        customerName: 'Ahmed Ali',
        area: 'Prince Sultan St, Al Rawdah',
        timeWindow: '12:00 — 14:00',
        status: TodayStopStatus.upNext,
      );
      await _pumpApp(tester, const OrderDetailPage(stop: ahmed));

      await tester.tap(find.byType(EtaPill));
      await tester.pumpAndSettle();

      expect(find.byType(SearchView), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Ahmed'), findsOneWidget);
      expect(find.text('3 RESULTS'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(SearchView), findsNothing);
      expect(find.byType(OrderDetailView), findsOneWidget);
    });
  });
}
