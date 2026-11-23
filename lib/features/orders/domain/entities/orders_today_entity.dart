// lib/features/orders/domain/entities/orders_today_entity.dart
import 'package:equatable/equatable.dart';

/// The two segments of the Orders tab header: the live day plan, and the
/// archive of everything already delivered.
enum OrdersTodaySegment { orders, history }

/// Where a stop stands in the driver's day.
///
/// Exactly one stop may be [onTheWay] — the one the driver is currently
/// driving to. It is the only row that renders the "On the way" pill instead
/// of a chevron, so the driver can spot their current job without reading.
///
/// A [cancelled] stop stays in the list, greyed and inert, instead of
/// vanishing: the package is still in the van, and the driver needs to see
/// why it no longer has a slot in the route.
enum TodayStopStatus { onTheWay, upNext, cancelled }

/// A single undelivered stop on today's route.
class TodayStopEntity extends Equatable {
  const TodayStopEntity({
    required this.id,
    required this.sequence,
    required this.customerName,
    required this.area,
    required this.timeWindow,
    required this.status,
  });

  final String id;

  /// Position in the day's route, as shown in the leading badge. This is the
  /// route number the dispatcher assigned, not the index in [todayStops] —
  /// delivered stops keep their numbers, so today's list starts at 3 once two
  /// are done.
  final int sequence;

  final String customerName;

  /// Street and district, e.g. `Tahlia St, Al Nahda`.
  final String area;

  /// The promised delivery window, e.g. `10:00 — 12:00`.
  final String timeWindow;

  final TodayStopStatus status;

  @override
  List<Object?> get props => [
        id,
        sequence,
        customerName,
        area,
        timeWindow,
        status,
      ];
}

/// One future day in the driver's schedule, collapsed to a single row.
class UpcomingDayEntity extends Equatable {
  const UpcomingDayEntity({
    required this.id,
    required this.dayLabel,
    required this.dateLabel,
    required this.ordersCount,
    required this.areas,
    this.newOrdersCount = 0,
  });

  final String id;

  /// A relative name when one reads better than the date (`Tomorrow`), or
  /// empty when the date carries the row on its own.
  final String dayLabel;

  /// The calendar date, e.g. `Mon 12 Oct`.
  final String dateLabel;

  /// All orders on the day, the new ones included.
  final int ordersCount;

  /// The districts the day covers, already ordered by stop count.
  final List<String> areas;

  /// How many of [ordersCount] dispatch added since the driver last looked.
  /// Drives the "N new" pill; zero hides it.
  final int newOrdersCount;

  /// `Tomorrow · Mon 12 Oct`, or just `Tue 13 Oct` when there is no relative
  /// name to lead with.
  String get title =>
      dayLabel.isEmpty ? dateLabel : '$dayLabel · $dateLabel';

  /// How the day reads inside a sentence: `tomorrow`, or the date when there
  /// is no relative name.
  String get nameInSentence =>
      dayLabel.isEmpty ? dateLabel : dayLabel.toLowerCase();

  @override
  List<Object?> get props =>
      [id, dayLabel, dateLabel, ordersCount, areas, newOrdersCount];
}

/// Everything the Orders / Today screen renders in one shot.
class OrdersTodayEntity extends Equatable {
  const OrdersTodayEntity({
    required this.newOrdersCount,
    required this.todayStops,
    required this.remainingCount,
    required this.estimatedFinishTime,
    required this.deliveredTodayCount,
    required this.upcomingDays,
    this.cancellationNotice,
    this.fleetName,
  });

  /// Orders dispatch added since the driver last looked. Zero hides the
  /// review banner entirely.
  final int newOrdersCount;

  final List<TodayStopEntity> todayStops;

  /// Stops still to do today. Kept separate from `todayStops.length` because
  /// the API owns the count — the list may be truncated.
  final int remainingCount;

  /// When the day is projected to end, e.g. `12:40`.
  final String estimatedFinishTime;

  /// Drives the "N delivered today" footer row; zero hides it.
  final int deliveredTodayCount;

  final List<UpcomingDayEntity> upcomingDays;

  /// The most recent cancellation the driver has not acknowledged yet, or
  /// null when there is nothing to tell them.
  final CancellationNoticeEntity? cancellationNotice;

  /// The fleet that dispatches to this driver, e.g. `Red Sea Express`.
  /// Null when the driver is not attached to one yet.
  final String? fleetName;

  /// Nothing to do and nothing to announce: no stops today, no later days,
  /// no new orders, no unread cancellation.
  ///
  /// Deliveries already made today do not count — they live in History, and
  /// the empty screen's button goes there.
  bool get isEmpty =>
      todayStops.isEmpty &&
      upcomingDays.isEmpty &&
      newOrdersCount == 0 &&
      cancellationNotice == null;

  @override
  List<Object?> get props => [
        newOrdersCount,
        todayStops,
        remainingCount,
        estimatedFinishTime,
        deliveredTodayCount,
        upcomingDays,
        cancellationNotice,
        fleetName,
      ];
}

/// Tells the driver a stop was pulled from their route, and what to do with
/// the package they are still carrying.
class CancellationNoticeEntity extends Equatable {
  const CancellationNoticeEntity({
    required this.orderId,
    required this.customerName,
    required this.orderCode,
    required this.cancelledAt,
  });

  /// The cancelled stop's id. Also the notice's identity: acknowledging it
  /// keeps it hidden across refreshes until a different order is cancelled.
  final String orderId;

  final String customerName;

  /// Printed reference without the `#`, e.g. `RX-1043`.
  final String orderCode;

  /// Local time of the cancellation, e.g. `9:58`.
  final String cancelledAt;

  @override
  List<Object?> get props => [orderId, customerName, orderCode, cancelledAt];
}
