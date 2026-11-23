// lib/features/orders/domain/entities/history_day_stops_entity.dart
import 'package:equatable/equatable.dart';

import 'order_history_entity.dart';

/// How a past stop ended.
enum HistoryStopOutcome { delivered, failed }

/// Who took the package at a delivered stop. Said in the outcome card,
/// because "delivered" alone does not settle a later "I never got it".
enum HandoverKind { customerAtDoor, reception, guard }

/// One stop of a finished (or running) day, in route order.
class HistoryStopEntity extends Equatable {
  const HistoryStopEntity({
    required this.sequence,
    required this.addressLine,
    required this.orderCode,
    required this.time,
    required this.outcome,
    this.failureReason,
    this.inReview = false,
    this.handover,
  });

  /// Position in that day's route.
  final int sequence;

  /// Street and district, e.g. `Sari St, Al Zahra`. The stop is named by
  /// where it was, not who it was for — that is how a driver remembers a
  /// day.
  final String addressLine;

  /// Without the `#`.
  final String orderCode;

  /// When it was delivered, or when the attempt failed, e.g. `08:31`.
  final String time;

  final HistoryStopOutcome outcome;

  /// Why it failed; null when it did not.
  final DeliveryFailureReason? failureReason;

  /// Dispatch is still checking this one — a failure being verified, or a
  /// photo or signature under review.
  final bool inReview;

  /// For a delivered stop, who took it; null when not recorded.
  final HandoverKind? handover;

  @override
  List<Object?> get props => [
        sequence,
        addressLine,
        orderCode,
        time,
        outcome,
        failureReason,
        inReview,
        handover,
      ];
}

/// The stops of one day, plus when the shift ran.
class HistoryDayStopsEntity extends Equatable {
  const HistoryDayStopsEntity({
    required this.dayId,
    required this.stops,
    this.shiftStart = '',
    this.shiftEnd = '',
  });

  final String dayId;
  final List<HistoryStopEntity> stops;

  /// First and last activity of the shift, e.g. `08:05` and `12:10`.
  /// Either empty hides the span.
  final String shiftStart;
  final String shiftEnd;

  @override
  List<Object?> get props => [dayId, stops, shiftStart, shiftEnd];
}
