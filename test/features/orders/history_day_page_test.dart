import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'history_test_support.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/features/orders/data/datasources/history_day_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/history_day_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/entities/history_day_stops_entity.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_history_entity.dart';
import 'package:routex_mobile/features/orders/domain/repositories/history_day_repository.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_history_day_stops_usecase.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_day_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_page.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/history_stop_tile.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_empty_state.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_today/orders_row_tile.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_today/orders_skeleton_box.dart';

const _designSize = Size(412, 917);

const _saturday = HistoryDayEntity(
  id: '2025-10-10',
  dateLabel: 'Sat 10 Oct',
  fullDateLabel: 'Saturday, 10 Oct',
  kind: HistoryDayKind.worked,
  delivered: 7,
  total: 8,
  minutesOnRoad: 245,
  distanceKm: 38,
  inReviewCount: 1,
);

void _registerStops(HistoryDayRepository repository) {
  if (getIt.isRegistered<GetHistoryDayStopsUseCase>()) {
    getIt.unregister<GetHistoryDayStopsUseCase>();
  }
  getIt.registerLazySingleton<GetHistoryDayStopsUseCase>(
    () => GetHistoryDayStopsUseCase(repository),
  );
}

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
}

/// Lands the zero-delay mock's timer.
Future<void> _settleStops(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump();
}

class _FailingOnceRepository implements HistoryDayRepository {
  bool fail = true;

  @override
  Future<HistoryDayStopsEntity> getDayStops(String dayId) async {
    if (fail) throw Exception('offline');
    return const HistoryDayLocalDataSourceImpl().getDayStops(dayId);
  }
}

void main() {
  setUp(() => _registerStops(
        const HistoryDayRepositoryImpl(
          localDataSource: HistoryDayLocalDataSourceImpl(),
        ),
      ));
  tearDown(() {
    if (getIt.isRegistered<GetHistoryDayStopsUseCase>()) {
      getIt.unregister<GetHistoryDayStopsUseCase>();
    }
  });

  testWidgets('Saturday matches the design', (tester) async {
    await _pumpApp(tester, const HistoryDayPage(day: _saturday));
    await _settleStops(tester);

    expect(find.text('History'), findsOneWidget);
    expect(find.text('Saturday, 10 Oct'), findsOneWidget);
    expect(find.text('7 of 8'), findsOneWidget);
    expect(find.text('Delivered'), findsOneWidget);
    expect(find.text('4h 05m'), findsOneWidget);
    expect(find.text('On the road'), findsOneWidget);
    expect(find.text('38 km'), findsOneWidget);
    expect(find.text('Driven'), findsOneWidget);

    expect(find.text('STOPS'), findsOneWidget);
    expect(find.text('08:05 — 12:10'), findsOneWidget);

    expect(find.byType(HistoryStopTile), findsNWidgets(8));
    expect(find.text('Sari St, Al Zahra'), findsOneWidget);
    expect(find.text('#RX-1009 · 08:31'), findsOneWidget);
    expect(
      find.text('#RX-1015 · 09:52 · Customer not answering'),
      findsOneWidget,
    );
    // Only the stop under review wears the pill.
    expect(find.text('In review'), findsOneWidget);
  });

  testWidgets('a failed stop keeps its number in grey', (tester) async {
    await _pumpApp(tester, const HistoryDayPage(day: _saturday));
    await _settleStops(tester);

    Color badgeOf(String street) => tester
        .widget<OrdersRowBadge>(
          find.descendant(
            of: find.widgetWithText(HistoryStopTile, street),
            matching: find.byType(OrdersRowBadge),
          ),
        )
        .background ??
        // null means the badge follows the theme default.
        AppColors.surfaceBadge;

    expect(badgeOf('Sari St, Al Zahra'), AppColors.brandMain);
    expect(badgeOf('Tahlia St, Al Nahda'), AppColors.surfaceBadge);
  });

  testWidgets('title and figures paint at once; only the stops wait',
      (tester) async {
    _registerStops(
      const HistoryDayRepositoryImpl(
        localDataSource: HistoryDayLocalDataSourceImpl(
          loadDelay: Duration(milliseconds: 600),
        ),
      ),
    );
    await _pumpApp(tester, const HistoryDayPage(day: _saturday));

    expect(find.text('Saturday, 10 Oct'), findsOneWidget);
    expect(find.text('7 of 8'), findsOneWidget);
    expect(find.byType(OrdersSkeletonPulse), findsOneWidget);
    expect(find.byType(HistoryStopTile), findsNothing);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(find.byType(OrdersSkeletonPulse), findsNothing);
    expect(find.byType(HistoryStopTile), findsNWidgets(8));
  });

  testWidgets('a day still running shows its count so far, without a total',
      (tester) async {
    const today = HistoryDayEntity(
      id: '2025-10-11',
      dayLabel: 'Today',
      dateLabel: 'Sun 11 Oct',
      fullDateLabel: 'Sunday, 11 Oct',
      kind: HistoryDayKind.inProgress,
      delivered: 2,
      distanceKm: 18,
    );
    await _pumpApp(tester, const HistoryDayPage(day: today));
    await _settleStops(tester);

    expect(find.text('Sunday, 11 Oct'), findsOneWidget);
    expect(find.textContaining(' of '), findsNothing);
    expect(find.text('On the road'), findsNothing);
    expect(find.byType(HistoryStopTile), findsNWidgets(2));
  });

  testWidgets('a failed load offers Try again, which recovers',
      (tester) async {
    final repository = _FailingOnceRepository();
    _registerStops(repository);
    await _pumpApp(tester, const HistoryDayPage(day: _saturday));
    await tester.pump();

    expect(find.byType(OrdersEmptyState), findsOneWidget);
    // The figures already known stay on screen.
    expect(find.text('7 of 8'), findsOneWidget);

    repository.fail = false;
    await tester.ensureVisible(find.text('Try again'));
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await _settleStops(tester);

    expect(find.byType(OrdersEmptyState), findsNothing);
    expect(find.byType(HistoryStopTile), findsNWidgets(8));
  });

  group('opened from the History tab', () {
    setUp(registerHistory);
    tearDown(unregisterHistory);

    Future<void> pumpTab(WidgetTester tester) async {
      await _pumpApp(tester, const Scaffold(body: HistoryPage()));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
    }

    testWidgets('tapping "1 in review" opens that day', (tester) async {
      await pumpTab(tester);

      await tester.ensureVisible(find.text('1 in review'));
      await tester.tap(find.text('1 in review'));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryDayPage), findsOneWidget);
      expect(find.text('Saturday, 10 Oct'), findsOneWidget);
    });

    testWidgets('a day off does not open', (tester) async {
      await pumpTab(tester);

      await tester.ensureVisible(find.text('Day off'));
      await tester.tap(find.text('Day off'));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryDayPage), findsNothing);
    });
  });
}
