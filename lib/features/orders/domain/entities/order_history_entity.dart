// lib/features/orders/domain/entities/order_history_entity.dart
import 'package:equatable/equatable.dart';

/// The span the History tab summarises — the chips under the segmented
/// control.
enum HistoryPeriod { today, week, month }

/// How the period's volume compares with the driver's own norm. A verdict,
/// not a number, so the screen can say it in a sentence.
enum HistoryComparison { busier, usual, quieter }

/// Why a delivery failed. Only the most frequent one is shown.
enum DeliveryFailureReason { customerNotAnswering, addressNotFound, refused }

/// One bar of the chart: a day of the week, a week of the month, or a slot
/// of today.
class HistoryBarEntity extends Equatable {
  const HistoryBarEntity({
    required this.label,
    required this.deliveries,
    this.isCurrent = false,
    this.fullLabel = '',
  });

  /// Short axis label from the server, e.g. `M` or `W2`.
  final String label;

  /// The same slot spelled out for a heading, e.g. `Wednesday, 7 Oct`.
  /// Empty falls back to [label].
  final String fullLabel;

  final int deliveries;

  /// The bar for now — today, this week — drawn in brand green.
  final bool isCurrent;

  String get heading => fullLabel.isEmpty ? label : fullLabel;

  @override
  List<Object?> get props => [label, fullLabel, deliveries, isCurrent];
}

/// How many deliveries failed for one reason.
class HistoryFailureCountEntity extends Equatable {
  const HistoryFailureCountEntity({required this.reason, required this.count});

  final DeliveryFailureReason reason;
  final int count;

  @override
  List<Object?> get props => [reason, count];
}

enum HistoryDayKind {
  /// Today, still under way: counts are "so far" and there is no total yet.
  inProgress,

  /// A finished working day.
  worked,

  /// No shift — listed so a gap in the week reads as rest, not missing data.
  dayOff,
}

/// One day in the list under the summary.
class HistoryDayEntity extends Equatable {
  const HistoryDayEntity({
    required this.id,
    required this.dateLabel,
    required this.kind,
    this.dayLabel = '',
    this.delivered = 0,
    this.total = 0,
    this.minutesOnRoad = 0,
    this.distanceKm = 0,
    this.inReviewCount = 0,
    this.fullDateLabel = '',
  });

  final String id;

  /// A relative name (`Today`), or empty when the date stands alone.
  final String dayLabel;

  /// `Sun 11 Oct`.
  final String dateLabel;

  /// The same date spelled out for a page title, `Saturday, 10 Oct`. Empty
  /// falls back to [dateLabel].
  final String fullDateLabel;

  String get heading => fullDateLabel.isEmpty ? dateLabel : fullDateLabel;

  final HistoryDayKind kind;
  final int delivered;
  final int total;
  final int minutesOnRoad;
  final int distanceKm;

  /// Deliveries dispatch is still checking — a photo or signature being
  /// reviewed. Shown as a pill; zero hides it.
  final int inReviewCount;

  String get title =>
      dayLabel.isEmpty ? dateLabel : '$dayLabel · $dateLabel';

  @override
  List<Object?> get props => [
        id,
        dayLabel,
        dateLabel,
        kind,
        delivered,
        total,
        minutesOnRoad,
        distanceKm,
        inReviewCount,
        fullDateLabel,
      ];
}

/// One week in the month's list.
class HistoryWeekEntity extends Equatable {
  const HistoryWeekEntity({
    required this.id,
    required this.rangeLabel,
    required this.delivered,
    this.failed = 0,
    this.isCurrent = false,
  });

  final String id;

  /// `5 — 11 Oct`, formatted by the server.
  final String rangeLabel;

  final int delivered;

  /// Deliveries that could not be made. Zero leaves it out of the row.
  final int failed;

  /// The week under way — titled "This week" and opened as the Week tab.
  final bool isCurrent;

  @override
  List<Object?> get props => [id, rangeLabel, delivered, failed, isCurrent];
}

/// Everything the History tab shows for one [HistoryPeriod].
class OrderHistoryEntity extends Equatable {
  const OrderHistoryEntity({
    required this.period,
    required this.rangeLabel,
    required this.deliveries,
    required this.comparison,
    required this.bars,
    required this.deliveredPercent,
    required this.distanceKm,
    required this.minutesOnRoad,
    required this.failedCount,
    required this.days,
    this.mostCommonFailure,
    this.assignedCount = 0,
    this.usualPerBar = 0,
    this.usualTotal = 0,
    this.drivingMinutes = 0,
    this.stopMinutes = 0,
    this.workedDays = 0,
    this.failures = const [],
    this.fleetName,
    this.usualDeliveredPercent = 0,
    this.weeks = const [],
    this.hasSummary = true,
  });

  final HistoryPeriod period;

  /// The dates covered, e.g. `5 — 11 Oct`, formatted by the server.
  final String rangeLabel;

  final int deliveries;
  final HistoryComparison comparison;
  final List<HistoryBarEntity> bars;

  /// Share of assigned orders delivered, 0–100.
  final int deliveredPercent;

  final int distanceKm;
  final int minutesOnRoad;

  /// Deliveries that could not be made. Zero hides the card.
  final int failedCount;

  /// The most frequent reason behind [failedCount]; null when there were
  /// none, or no single reason stands out.
  final DeliveryFailureReason? mostCommonFailure;

  /// Newest first.
  final List<HistoryDayEntity> days;

  /// Nothing delivered in the period yet — a new driver, the first day of a
  /// week, or simply no orders. There is no shape to chart and no usual to
  /// compare against, so the tab says so instead of drawing zeros.
  bool get hasNoDeliveries => hasSummary && deliveries == 0;

  /// False when the server sent the period's days but could not work out its
  /// summary — the figures, chart and comparison are then placeholders and
  /// must not be shown. The days, weeks and failures are still good.
  final bool hasSummary;

  // ── The detail screen's figures ──────────────────────────────────────

  /// Orders assigned over the period, cancelled ones excluded — the
  /// denominator behind [deliveredPercent].
  final int assignedCount;

  /// The driver's own average for one bar's slot — "your usual day: 4.4" —
  /// drawn as the dashed line across the chart.
  final double usualPerBar;

  /// The driver's usual total for a whole period, for "4 more than your
  /// usual week".
  final int usualTotal;

  /// [minutesOnRoad] split: moving, and parked at a stop.
  final int drivingMinutes;
  final int stopMinutes;

  /// Days with at least one shift, so distance can be put per day worked
  /// rather than per calendar day.
  final int workedDays;

  /// Every reason behind [failedCount], with its count. Ordered by count.
  final List<HistoryFailureCountEntity> failures;

  /// The fleet whose dispatch can see these numbers. Null when the driver
  /// is not attached to one.
  final String? fleetName;

  // ── The month's extras ───────────────────────────────────────────────

  /// The driver's own norm for [deliveredPercent], 0–100; zero when there
  /// is not enough history to have one.
  final int usualDeliveredPercent;

  /// The month's weeks, newest first. Empty for a day or a week.
  final List<HistoryWeekEntity> weeks;

  /// Delivered is under the driver's own norm and one reason explains most
  /// of it — the case worth a card of its own on the month.
  bool get deliveredBelowUsual =>
      usualDeliveredPercent > 0 &&
      deliveredPercent < usualDeliveredPercent &&
      mostCommonFailure != null;

  /// How many failures [mostCommonFailure] accounts for.
  int get mostCommonFailureCount => failures
      .where((f) => f.reason == mostCommonFailure)
      .fold(0, (sum, f) => sum + f.count);

  @override
  List<Object?> get props => [
        period,
        rangeLabel,
        deliveries,
        comparison,
        bars,
        deliveredPercent,
        distanceKm,
        minutesOnRoad,
        failedCount,
        mostCommonFailure,
        days,
        assignedCount,
        usualPerBar,
        usualTotal,
        drivingMinutes,
        stopMinutes,
        workedDays,
        failures,
        fleetName,
        usualDeliveredPercent,
        weeks,
        hasSummary,
      ];
}
