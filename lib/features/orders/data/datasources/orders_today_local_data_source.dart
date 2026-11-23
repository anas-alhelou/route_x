// lib/features/orders/data/datasources/orders_today_local_data_source.dart
import '../../domain/entities/orders_today_entity.dart';
import '../models/orders_today_model.dart';

abstract class OrdersTodayLocalDataSource {
  Future<OrdersTodayModel> getOrdersToday();
}

/// Which day the mock serves. Lets each designed state of the screen be
/// reached in the app without a backend to put it there.
enum OrdersTodayMockScenario {
  /// Three open stops and a "new orders" banner.
  normal,

  /// Sara Mansour's order cancelled by dispatch, with the notice unread.
  withCancellation,

  /// Nothing assigned yet — the "No orders right now" screen.
  empty,
}

/// Stand-in for the dispatch API until it ships.
///
/// The [loadDelay] is deliberate, not an artefact: the screen is specified to
/// show its skeleton for 1500 ms so the layout the driver is about to read is
/// already in place when the data lands.
class OrdersTodayLocalDataSourceImpl implements OrdersTodayLocalDataSource {
  const OrdersTodayLocalDataSourceImpl({
    this.loadDelay = const Duration(milliseconds: 1500),
    this.scenario = OrdersTodayMockScenario.normal,
  });

  final Duration loadDelay;
  final OrdersTodayMockScenario scenario;

  static const TodayStopModel _lina = TodayStopModel(
    id: 'ORD-10031',
    sequence: 3,
    customerName: 'Lina Fares',
    area: 'Tahlia St, Al Nahda',
    timeWindow: '10:00 — 12:00',
    status: TodayStopStatus.onTheWay,
  );

  static const TodayStopModel _ahmed = TodayStopModel(
    id: 'ORD-10032',
    sequence: 4,
    customerName: 'Ahmed Ali',
    area: 'Prince Sultan St, Al Rawdah',
    timeWindow: '12:00 — 14:00',
    status: TodayStopStatus.upNext,
  );

  static const String _fleet = 'Red Sea Express';

  static const OrdersTodayModel _empty = OrdersTodayModel(
    newOrdersCount: 0,
    remainingCount: 0,
    estimatedFinishTime: '',
    deliveredTodayCount: 0,
    todayStops: [],
    upcomingDays: [],
    fleetName: _fleet,
  );

  static const List<UpcomingDayModel> _upcoming = [
    UpcomingDayModel(
      id: '2025-10-12',
      dayLabel: 'Tomorrow',
      dateLabel: 'Mon 12 Oct',
      ordersCount: 4,
      areas: ['Al Rawdah', 'Al Zahra'],
    ),
    UpcomingDayModel(
      id: '2025-10-13',
      dayLabel: '',
      dateLabel: 'Tue 13 Oct',
      ordersCount: 2,
      areas: ['Al Nahda'],
    ),
  ];

  static const OrdersTodayModel _normal = OrdersTodayModel(
    newOrdersCount: 2,
    remainingCount: 3,
    estimatedFinishTime: '12:40',
    deliveredTodayCount: 2,
    todayStops: [
      _lina,
      _ahmed,
      TodayStopModel(
        id: 'ORD-10033',
        sequence: 5,
        customerName: 'Sara Mansour',
        area: 'Al Salamah',
        timeWindow: '12:00 — 14:00',
        status: TodayStopStatus.upNext,
      ),
    ],
    upcomingDays: _upcoming,
    fleetName: _fleet,
  );

  static const OrdersTodayModel _withCancellation = OrdersTodayModel(
    // Waits behind the notice: shown once the driver taps OK.
    newOrdersCount: 2,
    // Sara no longer counts: two stops left, and the day ends earlier.
    remainingCount: 2,
    estimatedFinishTime: '12:10',
    deliveredTodayCount: 2,
    todayStops: [
      _lina,
      _ahmed,
      TodayStopModel(
        id: 'ORD-10033',
        sequence: 5,
        customerName: 'Sara Mansour',
        area: 'Al Salamah',
        timeWindow: '12:00 — 14:00',
        status: TodayStopStatus.cancelled,
      ),
    ],
    upcomingDays: _upcoming,
    fleetName: _fleet,
    cancellationNotice: CancellationNoticeModel(
      orderId: 'ORD-10033',
      customerName: 'Sara Mansour',
      orderCode: 'RX-1043',
      cancelledAt: '9:58',
    ),
  );

  @override
  Future<OrdersTodayModel> getOrdersToday() async {
    await Future<void>.delayed(loadDelay);
    return switch (scenario) {
      OrdersTodayMockScenario.normal => _normal,
      OrdersTodayMockScenario.withCancellation => _withCancellation,
      OrdersTodayMockScenario.empty => _empty,
    };
  }
}

/// Simulates dispatch adding orders while the driver has the list open: the
/// first load is the day as it stood, and every load after it has two more
/// orders on tomorrow — what a pull-to-refresh would find after dispatch
/// assigned them.
///
/// Stateful, unlike [OrdersTodayLocalDataSourceImpl], because "arrived" only
/// means something against an earlier answer.
class OrdersTodayArrivalMockDataSource implements OrdersTodayLocalDataSource {
  OrdersTodayArrivalMockDataSource({
    this.loadDelay = const Duration(milliseconds: 1500),
  });

  final Duration loadDelay;
  int _calls = 0;

  static const List<TodayStopModel> _stops = [
    OrdersTodayLocalDataSourceImpl._lina,
    OrdersTodayLocalDataSourceImpl._ahmed,
    TodayStopModel(
      id: 'ORD-10033',
      sequence: 5,
      customerName: 'Sara Mansour',
      area: 'Al Salamah',
      timeWindow: '12:00 — 14:00',
      status: TodayStopStatus.upNext,
    ),
  ];

  static const UpcomingDayModel _tuesday = UpcomingDayModel(
    id: '2025-10-13',
    dayLabel: '',
    dateLabel: 'Tue 13 Oct',
    ordersCount: 2,
    areas: ['Al Nahda'],
  );

  static const OrdersTodayModel _before = OrdersTodayModel(
    newOrdersCount: 0,
    remainingCount: 3,
    estimatedFinishTime: '12:40',
    deliveredTodayCount: 2,
    todayStops: _stops,
    upcomingDays: [
      UpcomingDayModel(
        id: '2025-10-12',
        dayLabel: 'Tomorrow',
        dateLabel: 'Mon 12 Oct',
        ordersCount: 4,
        areas: ['Al Rawdah', 'Al Zahra'],
      ),
      _tuesday,
    ],
    fleetName: OrdersTodayLocalDataSourceImpl._fleet,
  );

  static const OrdersTodayModel _after = OrdersTodayModel(
    newOrdersCount: 0,
    remainingCount: 3,
    estimatedFinishTime: '12:40',
    deliveredTodayCount: 2,
    todayStops: _stops,
    upcomingDays: [
      UpcomingDayModel(
        id: '2025-10-12',
        dayLabel: 'Tomorrow',
        dateLabel: 'Mon 12 Oct',
        ordersCount: 6,
        areas: ['Al Rawdah', 'Al Zahra', 'Al Nahda'],
        newOrdersCount: 2,
      ),
      _tuesday,
    ],
    fleetName: OrdersTodayLocalDataSourceImpl._fleet,
  );

  @override
  Future<OrdersTodayModel> getOrdersToday() async {
    await Future<void>.delayed(loadDelay);
    return _calls++ == 0 ? _before : _after;
  }
}
