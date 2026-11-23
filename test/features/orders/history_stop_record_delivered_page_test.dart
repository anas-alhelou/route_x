import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/orders/data/datasources/history_day_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/datasources/history_stop_record_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/datasources/stop_issue_remote_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/history_day_repository_impl.dart';
import 'package:routex_mobile/features/orders/data/repositories/history_stop_record_repository_impl.dart';
import 'package:routex_mobile/features/orders/data/repositories/stop_issue_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/entities/history_day_stops_entity.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_history_entity.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_history_day_stops_usecase.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_history_stop_record_usecase.dart';
import 'package:routex_mobile/features/orders/domain/usecases/report_stop_issue_usecase.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_day_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_issue_sent_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_stop_record_delivered_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_stop_record_page.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/proof_of_delivery_card.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/stop_record_widgets.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_today/orders_arrival_toast.dart';

const _designSize = Size(412, 917);

const _sari = HistoryStopEntity(
  sequence: 1,
  addressLine: 'Sari St, Al Zahra',
  orderCode: 'RX-1009',
  time: '08:31',
  outcome: HistoryStopOutcome.delivered,
  handover: HandoverKind.customerAtDoor,
);

const _saturday = HistoryDayEntity(
  id: '2025-10-10',
  dateLabel: 'Sat 10 Oct',
  fullDateLabel: 'Saturday, 10 Oct',
  kind: HistoryDayKind.worked,
  delivered: 7,
  total: 8,
  minutesOnRoad: 245,
  distanceKm: 38,
);

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
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump();
}

void main() {
  setUp(() {
    getIt.registerLazySingleton<GetHistoryStopRecordUseCase>(
      () => const GetHistoryStopRecordUseCase(
        HistoryStopRecordRepositoryImpl(
          localDataSource: HistoryStopRecordLocalDataSourceImpl(),
        ),
      ),
    );
  });
  tearDown(() => getIt.unregister<GetHistoryStopRecordUseCase>());

  testWidgets('RX-1009 matches the design', (tester) async {
    await _pumpApp(
      tester,
      HistoryStopRecordDeliveredPage(
        stop: _sari,
        dayLabel: 'Sat 10 Oct',
        totalStops: 8,
      ),
    );

    expect(find.text('Sat 10 Oct'), findsOneWidget);
    // Pill and card title.
    expect(find.text('Delivered'), findsNWidgets(2));
    expect(find.text('#RX-1009 · Stop 1 of 8'), findsOneWidget);
    expect(find.text('Sari St, Al Zahra'), findsOneWidget);
    expect(find.text('Handed to the customer at the door.'), findsOneWidget);
    expect(
      tester.widget<StopOutcomeCard>(find.byType(StopOutcomeCard)).tone,
      StopOutcomeTone.positive,
    );

    expect(find.text('PROOF OF DELIVERY'), findsOneWidget);
    expect(find.text('Photo · 08:31 · 14 m away'), findsOneWidget);
    expect(find.text('Signature · 08:31'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Marked delivered'), 200);
    expect(find.text('Arrived'), findsOneWidget);
    expect(find.text('GPS: 14 m from the address'), findsOneWidget);
    expect(find.text('Called the customer'), findsOneWidget);
    expect(find.text('Answered'), findsOneWidget);
    expect(find.text('Photo taken'), findsOneWidget);
    expect(find.text('Package at the door, number 12'), findsOneWidget);
    expect(find.text('Signed by the customer'), findsOneWidget);
    expect(find.text('Marked delivered'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Report an issue with this stop'),
      200,
    );
    expect(find.text('Report an issue with this stop'), findsOneWidget);
  });

  testWidgets('says who took it: reception', (tester) async {
    await _pumpApp(
      tester,
      HistoryStopRecordDeliveredPage(
        stop: const HistoryStopEntity(
          sequence: 2,
          addressLine: 'Al Madinah Rd, Al Nahda',
          orderCode: 'RX-1011',
          time: '08:58',
          outcome: HistoryStopOutcome.delivered,
          handover: HandoverKind.reception,
        ),
        dayLabel: 'Sat 10 Oct',
        totalStops: 8,
      ),
    );

    expect(find.text('Left with reception.'), findsOneWidget);
  });

  testWidgets('a photo alone keeps its slot; no signature tile',
      (tester) async {
    await _pumpApp(
      tester,
      HistoryStopRecordDeliveredPage(
        stop: const HistoryStopEntity(
          sequence: 3,
          addressLine: 'Palestine St, Al Salamah',
          orderCode: 'RX-1012',
          time: '09:20',
          outcome: HistoryStopOutcome.delivered,
          handover: HandoverKind.customerAtDoor,
        ),
        dayLabel: 'Sat 10 Oct',
        totalStops: 8,
      ),
    );

    expect(find.byType(ProofOfDeliveryCard), findsOneWidget);
    expect(find.textContaining('Photo · 09:20'), findsOneWidget);
    expect(find.textContaining('Signature'), findsNothing);
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

    testWidgets('a delivered stop opens the delivered record',
        (tester) async {
      await _pumpApp(tester, const HistoryDayPage(day: _saturday));

      await tester.tap(find.text('Sari St, Al Zahra'));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryStopRecordDeliveredPage), findsOneWidget);
      expect(find.text('PROOF OF DELIVERY'), findsOneWidget);
    });

    testWidgets('stop 4, which failed, still opens the failed record',
        (tester) async {
      await _pumpApp(tester, const HistoryDayPage(day: _saturday));

      await tester.ensureVisible(find.text('Tahlia St, Al Nahda'));
      await tester.tap(find.text('Tahlia St, Al Nahda'));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryStopRecordPage), findsOneWidget);
      expect(find.byType(HistoryStopRecordDeliveredPage), findsNothing);
      expect(find.byType(ProofOfDeliveryCard), findsNothing);
    });
  });

  testWidgets('reporting a delivered stop keeps it green, not flagged red',
      (tester) async {
    getIt.registerLazySingleton<ReportStopIssueUseCase>(
      () => const ReportStopIssueUseCase(
        StopIssueRepositoryImpl(
          dataSource: StopIssueMockDataSource(delay: Duration.zero),
        ),
      ),
    );
    addTearDown(() => getIt.unregister<ReportStopIssueUseCase>());

    await _pumpApp(
      tester,
      HistoryStopRecordDeliveredPage(
        stop: _sari,
        dayLabel: 'Sat 10 Oct',
        totalStops: 8,
      ),
    );
    final report = find.text('Report an issue with this stop');
    await tester.scrollUntilVisible(report, 200);
    await tester.tap(report);
    await tester.pumpAndSettle();
    await tester.tap(find.text('The times are wrong'));
    await tester.pump();
    await tester.tap(find.text('Send to dispatch'));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryIssueSentPage), findsOneWidget);
    expect(
      tester.widget<StopOutcomeCard>(find.byType(StopOutcomeCard)).tone,
      StopOutcomeTone.positive,
    );

    await tester.pump(OrdersArrivalToast.visibleFor);
    await tester.pumpAndSettle();
  });
}
