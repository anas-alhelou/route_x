// lib/features/orders/data/datasources/order_history_local_data_source.dart
import '../../domain/entities/order_history_entity.dart';

abstract class OrderHistoryLocalDataSource {
  Future<OrderHistoryEntity> getHistory(HistoryPeriod period);
}

/// Stand-in for `GET /drivers/me/history?period=` until the API ships.
///
/// [loadDelay] mirrors the Orders tab: the skeleton holds for 1500 ms so the
/// layout is in place before the numbers land.
class OrderHistoryLocalDataSourceImpl implements OrderHistoryLocalDataSource {
  const OrderHistoryLocalDataSourceImpl({
    this.loadDelay = const Duration(milliseconds: 1500),
    this.scenario = OrderHistoryMockScenario.normal,
  });

  final Duration loadDelay;
  final OrderHistoryMockScenario scenario;

  static const String _fleet = 'Red Sea Express';

  static const HistoryDayEntity _today = HistoryDayEntity(
    id: '2025-10-11',
    dayLabel: 'Today',
    dateLabel: 'Sun 11 Oct',
    fullDateLabel: 'Sunday, 11 Oct',
    kind: HistoryDayKind.inProgress,
    delivered: 2,
    distanceKm: 18,
  );

  static const List<HistoryDayEntity> _week = [
    _today,
    HistoryDayEntity(
      id: '2025-10-10',
      dateLabel: 'Sat 10 Oct',
      fullDateLabel: 'Saturday, 10 Oct',
      kind: HistoryDayKind.worked,
      delivered: 7,
      total: 8,
      minutesOnRoad: 245,
      distanceKm: 38,
      inReviewCount: 1,
    ),
    HistoryDayEntity(
      id: '2025-10-09',
      dateLabel: 'Fri 9 Oct',
      fullDateLabel: 'Friday, 9 Oct',
      kind: HistoryDayKind.dayOff,
    ),
    HistoryDayEntity(
      id: '2025-10-08',
      dateLabel: 'Thu 8 Oct',
      fullDateLabel: 'Thursday, 8 Oct',
      kind: HistoryDayKind.worked,
      delivered: 4,
      total: 4,
      minutesOnRoad: 150,
      distanceKm: 24,
    ),
    HistoryDayEntity(
      id: '2025-10-07',
      dateLabel: 'Wed 7 Oct',
      fullDateLabel: 'Wednesday, 7 Oct',
      kind: HistoryDayKind.worked,
      delivered: 7,
      total: 8,
      minutesOnRoad: 280,
      distanceKm: 41,
    ),
    HistoryDayEntity(
      id: '2025-10-06',
      dateLabel: 'Tue 6 Oct',
      fullDateLabel: 'Tuesday, 6 Oct',
      kind: HistoryDayKind.worked,
      delivered: 5,
      total: 5,
      minutesOnRoad: 190,
      distanceKm: 29,
    ),
    HistoryDayEntity(
      id: '2025-10-05',
      dateLabel: 'Mon 5 Oct',
      fullDateLabel: 'Monday, 5 Oct',
      kind: HistoryDayKind.worked,
      delivered: 6,
      total: 6,
      minutesOnRoad: 235,
      distanceKm: 36,
    ),
  ];

  /// October, one bar a day: the first ten days, today (the 11th) under
  /// way, and the rest of the month still to come.
  static const List<HistoryBarEntity> _monthBars = [
    HistoryBarEntity(label: '1', fullLabel: 'Thursday, 1 Oct', deliveries: 6),
    HistoryBarEntity(label: '2', fullLabel: 'Friday, 2 Oct', deliveries: 0),
    HistoryBarEntity(label: '3', fullLabel: 'Saturday, 3 Oct', deliveries: 0),
    HistoryBarEntity(label: '4', fullLabel: 'Sunday, 4 Oct', deliveries: 7),
    HistoryBarEntity(label: '5', fullLabel: 'Monday, 5 Oct', deliveries: 6),
    HistoryBarEntity(label: '6', fullLabel: 'Tuesday, 6 Oct', deliveries: 9),
    HistoryBarEntity(label: '7', fullLabel: 'Wednesday, 7 Oct', deliveries: 4),
    HistoryBarEntity(label: '8', fullLabel: 'Thursday, 8 Oct', deliveries: 9),
    HistoryBarEntity(label: '9', fullLabel: 'Friday, 9 Oct', deliveries: 0),
    HistoryBarEntity(label: '10', fullLabel: 'Saturday, 10 Oct', deliveries: 9),
    HistoryBarEntity(
      label: '11',
      fullLabel: 'Sunday, 11 Oct',
      deliveries: 2,
      isCurrent: true,
    ),
    HistoryBarEntity(label: '12', deliveries: 0),
    HistoryBarEntity(label: '13', deliveries: 0),
    HistoryBarEntity(label: '14', deliveries: 0),
    HistoryBarEntity(label: '15', deliveries: 0),
    HistoryBarEntity(label: '16', deliveries: 0),
    HistoryBarEntity(label: '17', deliveries: 0),
    HistoryBarEntity(label: '18', deliveries: 0),
    HistoryBarEntity(label: '19', deliveries: 0),
    HistoryBarEntity(label: '20', deliveries: 0),
    HistoryBarEntity(label: '21', deliveries: 0),
    HistoryBarEntity(label: '22', deliveries: 0),
    HistoryBarEntity(label: '23', deliveries: 0),
    HistoryBarEntity(label: '24', deliveries: 0),
    HistoryBarEntity(label: '25', deliveries: 0),
    HistoryBarEntity(label: '26', deliveries: 0),
    HistoryBarEntity(label: '27', deliveries: 0),
    HistoryBarEntity(label: '28', deliveries: 0),
    HistoryBarEntity(label: '29', deliveries: 0),
    HistoryBarEntity(label: '30', deliveries: 0),
    HistoryBarEntity(label: '31', deliveries: 0),
  ];

  static const Map<HistoryPeriod, OrderHistoryEntity> _mock = {
    HistoryPeriod.today: OrderHistoryEntity(
      period: HistoryPeriod.today,
      rangeLabel: 'Sun 11 Oct',
      deliveries: 2,
      comparison: HistoryComparison.quieter,
      bars: [
        HistoryBarEntity(label: '8', fullLabel: '8:00 — 10:00', deliveries: 1),
        HistoryBarEntity(
          label: '10',
          fullLabel: '10:00 — 12:00',
          deliveries: 1,
          isCurrent: true,
        ),
        HistoryBarEntity(label: '12', fullLabel: '12:00 — 14:00', deliveries: 0),
        HistoryBarEntity(label: '2', fullLabel: '14:00 — 16:00', deliveries: 0),
        HistoryBarEntity(label: '4', fullLabel: '16:00 — 18:00', deliveries: 0),
        HistoryBarEntity(label: '6', fullLabel: '18:00 — 20:00', deliveries: 0),
      ],
      deliveredPercent: 100,
      distanceKm: 18,
      minutesOnRoad: 95,
      failedCount: 0,
      days: [_today],
      assignedCount: 2,
      usualPerBar: 0.8,
      usualTotal: 5,
      drivingMinutes: 70,
      stopMinutes: 25,
      workedDays: 1,
      fleetName: _fleet,
    ),
    HistoryPeriod.week: OrderHistoryEntity(
      period: HistoryPeriod.week,
      rangeLabel: '5 — 11 Oct',
      deliveries: 31,
      comparison: HistoryComparison.busier,
      bars: [
        HistoryBarEntity(label: 'M', fullLabel: 'Monday, 5 Oct', deliveries: 6),
        HistoryBarEntity(label: 'T', fullLabel: 'Tuesday, 6 Oct', deliveries: 5),
        HistoryBarEntity(label: 'W', fullLabel: 'Wednesday, 7 Oct', deliveries: 7),
        HistoryBarEntity(label: 'T', fullLabel: 'Thursday, 8 Oct', deliveries: 4),
        HistoryBarEntity(label: 'F', fullLabel: 'Friday, 9 Oct', deliveries: 0),
        HistoryBarEntity(label: 'S', fullLabel: 'Saturday, 10 Oct', deliveries: 7),
        HistoryBarEntity(
          label: 'S',
          fullLabel: 'Sunday, 11 Oct',
          deliveries: 2,
          isCurrent: true,
        ),
      ],
      deliveredPercent: 94,
      distanceKm: 186,
      minutesOnRoad: 1300,
      failedCount: 2,
      mostCommonFailure: DeliveryFailureReason.customerNotAnswering,
      days: _week,
      assignedCount: 33,
      usualPerBar: 4.4,
      usualTotal: 27,
      drivingMinutes: 910,
      stopMinutes: 390,
      workedDays: 5,
      failures: [
        HistoryFailureCountEntity(
          reason: DeliveryFailureReason.customerNotAnswering,
          count: 1,
        ),
        HistoryFailureCountEntity(
          reason: DeliveryFailureReason.addressNotFound,
          count: 1,
        ),
      ],
      fleetName: _fleet,
    ),
    HistoryPeriod.month: OrderHistoryEntity(
      period: HistoryPeriod.month,
      rangeLabel: '1 — 11 Oct',
      deliveries: 52,
      comparison: HistoryComparison.usual,
      bars: _monthBars,
      deliveredPercent: 92,
      usualDeliveredPercent: 96,
      distanceKm: 312,
      minutesOnRoad: 2175,
      failedCount: 4,
      mostCommonFailure: DeliveryFailureReason.customerNotAnswering,
      days: _week,
      assignedCount: 56,
      usualPerBar: 4.7,
      usualTotal: 52,
      drivingMinutes: 1550,
      stopMinutes: 625,
      workedDays: 8,
      failures: [
        HistoryFailureCountEntity(
          reason: DeliveryFailureReason.customerNotAnswering,
          count: 3,
        ),
        HistoryFailureCountEntity(
          reason: DeliveryFailureReason.addressNotFound,
          count: 1,
        ),
      ],
      weeks: [
        HistoryWeekEntity(
          id: '2025-10-05',
          rangeLabel: '5 — 11 Oct',
          delivered: 31,
          failed: 2,
          isCurrent: true,
        ),
        HistoryWeekEntity(
          id: '2025-09-28',
          rangeLabel: '28 Sep – 4 Oct',
          delivered: 21,
          failed: 2,
        ),
      ],
      fleetName: _fleet,
    ),
  };

  /// The same periods with nothing delivered: same ranges and axis labels,
  /// every bar at zero, no days to list.
  static OrderHistoryEntity _emptyOf(OrderHistoryEntity full) =>
      OrderHistoryEntity(
        period: full.period,
        rangeLabel: full.rangeLabel,
        deliveries: 0,
        comparison: HistoryComparison.usual,
        bars: [
          for (final bar in full.bars)
            HistoryBarEntity(
              label: bar.label,
              fullLabel: bar.fullLabel,
              deliveries: 0,
              isCurrent: bar.isCurrent,
            ),
        ],
        deliveredPercent: 0,
        distanceKm: 0,
        minutesOnRoad: 0,
        failedCount: 0,
        days: const [],
        fleetName: full.fleetName,
      );

  @override
  Future<OrderHistoryEntity> getHistory(HistoryPeriod period) async {
    await Future<void>.delayed(loadDelay);
    final full = _mock[period]!;
    return switch (scenario) {
      OrderHistoryMockScenario.normal => full,
      // Early in the week: nothing yet today or this week, but the month
      // has the weeks before it.
      OrderHistoryMockScenario.empty =>
        period == HistoryPeriod.month ? full : _emptyOf(full),
    };
  }
}

/// Which history the mock serves.
enum OrderHistoryMockScenario {
  /// The designed week, day and month.
  normal,

  /// The first day of a week: Today and Week have nothing delivered yet;
  /// Month still has the weeks before.
  empty,
}

/// The summary does not load the first time each period is asked for —
/// the days, weeks and failures do — and loads on the next try. Shows the
/// "summary didn't load" card and lets its Retry work.
class OrderHistorySummaryFailsOnceMockDataSource
    implements OrderHistoryLocalDataSource {
  OrderHistorySummaryFailsOnceMockDataSource({
    this.inner = const OrderHistoryLocalDataSourceImpl(),
  });

  final OrderHistoryLocalDataSource inner;
  final Set<HistoryPeriod> _served = {};

  @override
  Future<OrderHistoryEntity> getHistory(HistoryPeriod period) async {
    final full = await inner.getHistory(period);
    return _served.add(period) ? _withoutSummary(full) : full;
  }

  static OrderHistoryEntity _withoutSummary(OrderHistoryEntity full) =>
      OrderHistoryEntity(
        period: full.period,
        rangeLabel: full.rangeLabel,
        deliveries: 0,
        comparison: HistoryComparison.usual,
        bars: const [],
        deliveredPercent: 0,
        distanceKm: 0,
        minutesOnRoad: 0,
        failedCount: full.failedCount,
        mostCommonFailure: full.mostCommonFailure,
        failures: full.failures,
        days: full.days,
        weeks: full.weeks,
        fleetName: full.fleetName,
        hasSummary: false,
      );
}
