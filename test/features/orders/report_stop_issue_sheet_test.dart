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
import 'package:routex_mobile/features/orders/domain/entities/stop_issue_entity.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_history_day_stops_usecase.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_history_stop_record_usecase.dart';
import 'package:routex_mobile/features/orders/domain/usecases/report_stop_issue_usecase.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_day_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_issue_sent_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_stop_record_page.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/report_stop_issue_sheet.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/stop_record_widgets.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_today/orders_arrival_toast.dart';

const _designSize = Size(412, 917);
const _send = 'Send to dispatch';
const _sent = 'Sent. Thanks for flagging it.';

/// Records what was sent; can be told to fail, and how long to take.
class _RecordingSource implements StopIssueDataSource {
  final List<StopIssueEntity> sent = [];
  bool fail = false;

  static const delay = Duration(milliseconds: 300);

  @override
  Future<void> report(StopIssueEntity issue) async {
    await Future<void>.delayed(delay);
    if (fail) throw Exception('offline');
    sent.add(issue);
  }
}

late _RecordingSource _source;

Future<void> _openSheet(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(_designSize);
  tester.view.physicalSize = _designSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _designSize,
      builder: (context, child) => const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: HistoryStopRecordPage(
          dayLabel: 'Sat 10 Oct',
          totalStops: 8,
          stop: HistoryStopEntity(
            sequence: 4,
            addressLine: 'Tahlia St, Al Nahda',
            orderCode: 'RX-1015',
            time: '09:52',
            outcome: HistoryStopOutcome.failed,
            failureReason: DeliveryFailureReason.customerNotAnswering,
            inReview: true,
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump();

  final report = find.text('Report an issue with this stop');
  await tester.ensureVisible(report);
  await tester.tap(report);
  await tester.pumpAndSettle();
}

/// The confirmation toast leaves on a timer; run it out so the test ends
/// with none pending.
Future<void> _letToastGo(WidgetTester tester) async {
  await tester.pump(OrdersArrivalToast.visibleFor);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _source = _RecordingSource();
    getIt.registerLazySingleton<GetHistoryStopRecordUseCase>(
      () => const GetHistoryStopRecordUseCase(
        HistoryStopRecordRepositoryImpl(
          localDataSource: HistoryStopRecordLocalDataSourceImpl(),
        ),
      ),
    );
    getIt.registerLazySingleton<ReportStopIssueUseCase>(
      () => ReportStopIssueUseCase(
        StopIssueRepositoryImpl(dataSource: _source),
      ),
    );
  });
  tearDown(() {
    getIt.unregister<GetHistoryStopRecordUseCase>();
    getIt.unregister<ReportStopIssueUseCase>();
  });

  testWidgets('opens with four reasons and Send disabled', (tester) async {
    await _openSheet(tester);

    expect(find.byType(ReportStopIssueSheet), findsOneWidget);
    expect(find.text('What’s wrong with this stop?'), findsOneWidget);
    expect(find.text('The status is wrong'), findsOneWidget);
    expect(find.text('It wasn’t in my control'), findsOneWidget);
    expect(find.text('The times are wrong'), findsOneWidget);
    expect(find.text('Something else'), findsOneWidget);
    expect(find.text('Add details for dispatch (optional)'), findsOneWidget);

    await tester.tap(find.text(_send));
    await tester.pump(_RecordingSource.delay);
    expect(_source.sent, isEmpty, reason: 'nothing picked yet');
    expect(find.byType(ReportStopIssueSheet), findsOneWidget);
  });

  testWidgets('a reason and a note send, then the sheet closes and confirms',
      (tester) async {
    await _openSheet(tester);

    await tester.tap(find.text('It wasn’t in my control'));
    await tester.pump();
    await tester.enterText(
      find.byType(TextField),
      '  Building gate was locked and the guard wasn’t there.  ',
    );
    await tester.pump();

    await tester.tap(find.text(_send));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(_RecordingSource.delay);
    await tester.pumpAndSettle();

    expect(find.byType(ReportStopIssueSheet), findsNothing);
    // Lands on the record in its issue-sent state.
    expect(find.byType(HistoryIssueSentPage), findsOneWidget);
    expect(find.text(_sent), findsOneWidget);
    expect(find.text('Issue sent to dispatch'), findsOneWidget);
    expect(
      find.text('You’ll get their reply in Notifications.'),
      findsOneWidget,
    );
    // The report button is gone; the outcome is flagged.
    expect(find.text('Report an issue with this stop'), findsNothing);
    expect(
      tester.widget<StopOutcomeCard>(find.byType(StopOutcomeCard)).tone,
      StopOutcomeTone.flagged,
    );
    expect(_source.sent, [
      const StopIssueEntity(
        orderCode: 'RX-1015',
        kind: StopIssueKind.notInMyControl,
        note: 'Building gate was locked and the guard wasn’t there.',
      ),
    ]);

    await _letToastGo(tester);
  });

  testWidgets('"Something else" needs a note before it can send',
      (tester) async {
    await _openSheet(tester);

    await tester.tap(find.text('Something else'));
    await tester.pump();
    expect(find.text('Tell dispatch what happened'), findsOneWidget);

    await tester.tap(find.text(_send));
    await tester.pump(_RecordingSource.delay);
    expect(_source.sent, isEmpty);

    await tester.enterText(find.byType(TextField), 'Wrong building number');
    await tester.pump();
    await tester.tap(find.text(_send));
    await tester.pump(_RecordingSource.delay);
    await tester.pumpAndSettle();

    expect(_source.sent.single.kind, StopIssueKind.other);
    await _letToastGo(tester);
  });

  testWidgets('a failed send keeps the sheet and what was entered',
      (tester) async {
    _source.fail = true;
    await _openSheet(tester);

    await tester.tap(find.text('The times are wrong'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Arrived at 09:40');
    await tester.tap(find.text(_send));
    await tester.pump(_RecordingSource.delay);
    await tester.pump();

    expect(find.byType(ReportStopIssueSheet), findsOneWidget);
    expect(
      find.text('Couldn’t send. Check your signal and try again.'),
      findsOneWidget,
    );
    expect(find.text('Arrived at 09:40'), findsOneWidget);

    // Trying again goes through once the signal is back.
    _source.fail = false;
    await tester.tap(find.text(_send));
    await tester.pump(_RecordingSource.delay);
    await tester.pumpAndSettle();
    expect(_source.sent.single.kind, StopIssueKind.timesWrong);
    await _letToastGo(tester);
  });

  testWidgets('Cancel closes without sending', (tester) async {
    await _openSheet(tester);

    await tester.tap(find.text('The status is wrong'));
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(ReportStopIssueSheet), findsNothing);
    expect(find.text(_sent), findsNothing);
    expect(_source.sent, isEmpty);
  });

  testWidgets('after sending, Back returns to the day, not to the old record',
      (tester) async {
    getIt.registerLazySingleton<GetHistoryDayStopsUseCase>(
      () => const GetHistoryDayStopsUseCase(
        HistoryDayRepositoryImpl(
          localDataSource: HistoryDayLocalDataSourceImpl(),
        ),
      ),
    );
    addTearDown(() => getIt.unregister<GetHistoryDayStopsUseCase>());

    await tester.binding.setSurfaceSize(_designSize);
    tester.view.physicalSize = _designSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: _designSize,
        builder: (context, child) => const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: HistoryDayPage(
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
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    // Day → stop record → report → send.
    await tester.ensureVisible(find.text('In review'));
    await tester.tap(find.text('In review'));
    await tester.pumpAndSettle();
    final report = find.text('Report an issue with this stop');
    await tester.ensureVisible(report);
    await tester.tap(report);
    await tester.pumpAndSettle();
    await tester.tap(find.text('The status is wrong'));
    await tester.pump();
    await tester.tap(find.text(_send));
    await tester.pump(_RecordingSource.delay);
    await tester.pumpAndSettle();
    expect(find.byType(HistoryIssueSentPage), findsOneWidget);

    await tester.tap(find.text('Sat 10 Oct'));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryIssueSentPage), findsNothing);
    expect(
      find.byType(HistoryStopRecordPage),
      findsNothing,
      reason: 'the record was replaced, not stacked under the sent state',
    );
    expect(find.text('Saturday, 10 Oct'), findsOneWidget);
    await _letToastGo(tester);
  });

  test('the use case refuses "Something else" without a note', () {
    final useCase = ReportStopIssueUseCase(
      StopIssueRepositoryImpl(dataSource: _RecordingSource()),
    );

    expect(
      () => useCase(
        const StopIssueEntity(
          orderCode: 'RX-1015',
          kind: StopIssueKind.other,
          note: '   ',
        ),
      ),
      throwsArgumentError,
    );
  });
}
