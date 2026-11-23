import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/orders/data/datasources/history_day_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/datasources/history_stop_record_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/history_day_repository_impl.dart';
import 'package:routex_mobile/features/orders/data/repositories/history_stop_record_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/entities/history_day_stops_entity.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_history_entity.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_history_day_stops_usecase.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_history_stop_record_usecase.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_day_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_stop_record_page.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_today/orders_skeleton_box.dart';

const _designSize = Size(412, 917);

const _tahlia = HistoryStopEntity(
  sequence: 4,
  addressLine: 'Tahlia St, Al Nahda',
  orderCode: 'RX-1015',
  time: '09:52',
  outcome: HistoryStopOutcome.failed,
  failureReason: DeliveryFailureReason.customerNotAnswering,
  inReview: true,
);

const _sari = HistoryStopEntity(
  sequence: 1,
  addressLine: 'Sari St, Al Zahra',
  orderCode: 'RX-1009',
  time: '08:31',
  outcome: HistoryStopOutcome.delivered,
);

void _registerRecord({Duration delay = Duration.zero}) {
  if (getIt.isRegistered<GetHistoryStopRecordUseCase>()) {
    getIt.unregister<GetHistoryStopRecordUseCase>();
  }
  getIt.registerLazySingleton<GetHistoryStopRecordUseCase>(
    () => GetHistoryStopRecordUseCase(
      HistoryStopRecordRepositoryImpl(
        localDataSource: HistoryStopRecordLocalDataSourceImpl(loadDelay: delay),
      ),
    ),
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

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump();
}

void main() {
  setUp(_registerRecord);
  tearDown(() {
    if (getIt.isRegistered<GetHistoryStopRecordUseCase>()) {
      getIt.unregister<GetHistoryStopRecordUseCase>();
    }
  });

  testWidgets('RX-1015 matches the design', (tester) async {
    await _pumpApp(
      tester,
      const HistoryStopRecordPage(
        stop: _tahlia,
        dayLabel: 'Sat 10 Oct',
        totalStops: 8,
      ),
    );
    await _settle(tester);

    expect(find.text('Sat 10 Oct'), findsOneWidget);
    expect(find.text('In review'), findsOneWidget);
    expect(find.text('#RX-1015 · Stop 4 of 8'), findsOneWidget);
    expect(find.text('Tahlia St, Al Nahda'), findsOneWidget);

    expect(find.text('Couldn’t deliver'), findsOneWidget);
    expect(
      find.text('Customer not answering. Dispatch is checking it, nothing '
          'to do for now.'),
      findsOneWidget,
    );

    expect(find.text('WHAT HAPPENED'), findsOneWidget);
    expect(find.text('Arrived'), findsOneWidget);
    expect(find.text('09:44'), findsOneWidget);
    expect(find.text('GPS: 12 m from the address'), findsOneWidget);
    expect(find.text('Called the customer'), findsOneWidget);
    expect(find.text('No answer'), findsOneWidget);
    expect(find.text('Called again'), findsOneWidget);
    expect(find.text('No answer · waited 5 min'), findsOneWidget);
    expect(find.text('Marked couldn’t deliver'), findsOneWidget);
    expect(find.text('Reason: customer not answering'), findsOneWidget);
    expect(find.text('Package handed back at depot'), findsOneWidget);
    expect(find.text('15:20'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Report an issue with this stop'),
      200,
    );
    expect(
      find.text('Customer details are hidden once a stop is closed.'),
      findsOneWidget,
    );
    expect(find.text('Report an issue with this stop'), findsOneWidget);
  });

  testWidgets('a delivered stop with no recorded handover falls back to the '
      'time, with its own timeline', (tester) async {
    await _pumpApp(
      tester,
      const HistoryStopRecordPage(
        stop: _sari,
        dayLabel: 'Sat 10 Oct',
        totalStops: 8,
      ),
    );
    await _settle(tester);

    // Pill and card title.
    expect(find.text('Delivered'), findsNWidgets(2));
    expect(find.text('Handed over at 08:31.'), findsOneWidget);
    expect(find.text('Couldn’t deliver'), findsNothing);
    expect(find.text('In review'), findsNothing);

    expect(find.text('Arrived'), findsOneWidget);
    expect(find.text('Photo taken'), findsOneWidget);
    expect(find.text('Marked delivered'), findsOneWidget);
    expect(find.text('Marked couldn’t deliver'), findsNothing);
  });

  testWidgets('the header paints at once; only the log waits',
      (tester) async {
    _registerRecord(delay: const Duration(milliseconds: 500));
    await _pumpApp(
      tester,
      const HistoryStopRecordPage(
        stop: _tahlia,
        dayLabel: 'Sat 10 Oct',
        totalStops: 8,
      ),
    );

    expect(find.text('Tahlia St, Al Nahda'), findsOneWidget);
    expect(find.text('Couldn’t deliver'), findsOneWidget);
    expect(find.byType(OrdersSkeletonPulse), findsOneWidget);
    expect(find.text('Arrived'), findsNothing);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(find.byType(OrdersSkeletonPulse), findsNothing);
    expect(find.text('Arrived'), findsOneWidget);
  });

  group('opened from the day', () {
    setUp(() {
      getIt.registerLazySingleton<GetHistoryDayStopsUseCase>(
        () => const GetHistoryDayStopsUseCase(
          HistoryDayRepositoryImpl(
            localDataSource: HistoryDayLocalDataSourceImpl(),
          ),
        ),
      );
    });
    tearDown(() => getIt.unregister<GetHistoryDayStopsUseCase>());

    testWidgets('tapping the stop in review opens its record, and back '
        'returns to the day', (tester) async {
      await _pumpApp(
        tester,
        const HistoryDayPage(
          day: HistoryDayEntity(
            id: '2025-10-10',
            dateLabel: 'Sat 10 Oct',
            fullDateLabel: 'Saturday, 10 Oct',
            kind: HistoryDayKind.worked,
            delivered: 7,
            total: 8,
            minutesOnRoad: 245,
            distanceKm: 38,
          ),
        ),
      );
      await _settle(tester);

      await tester.ensureVisible(find.text('In review'));
      await tester.tap(find.text('In review'));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryStopRecordPage), findsOneWidget);
      expect(find.text('#RX-1015 · Stop 4 of 8'), findsOneWidget);

      await tester.tap(find.text('Sat 10 Oct'));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryStopRecordPage), findsNothing);
      expect(find.text('Saturday, 10 Oct'), findsOneWidget);
    });
  });
}
