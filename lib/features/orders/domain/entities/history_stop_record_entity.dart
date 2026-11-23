// lib/features/orders/domain/entities/history_stop_record_entity.dart
import 'package:equatable/equatable.dart';

import 'order_history_entity.dart';

/// Something that happened at a stop, as the app logged it.
enum StopEventKind {
  arrived,
  called,
  calledAgain,
  markedFailed,
  photoTaken,
  signed,

  /// The driver closed the stop as delivered.
  delivered,
  returnedToDepot,
}

/// One line of a stop's record — what happened, and when.
class StopEventEntity extends Equatable {
  const StopEventEntity({
    required this.kind,
    required this.time,
    this.distanceMeters,
    this.answered,
    this.waitedMinutes,
    this.reason,
    this.note,
  });

  final StopEventKind kind;

  /// `09:44`.
  final String time;

  /// For [StopEventKind.arrived]: how far the GPS fix was from the address.
  /// The driver's evidence that they were there.
  final int? distanceMeters;

  /// For a call: whether the customer picked up.
  final bool? answered;

  /// For a call: how long the driver waited after it.
  final int? waitedMinutes;

  /// For [StopEventKind.markedFailed]: the reason the driver chose.
  final DeliveryFailureReason? reason;

  /// What the driver typed at the time, e.g. "Package at the door, number
  /// 12" with a photo. Shown as written.
  final String? note;

  @override
  List<Object?> get props =>
      [kind, time, distanceMeters, answered, waitedMinutes, reason, note];
}

/// The photo taken at handover.
class DeliveryPhotoEntity extends Equatable {
  const DeliveryPhotoEntity({
    required this.time,
    this.distanceMeters,
    this.imageUrl,
  });

  final String time;

  /// How far from the address the photo was taken.
  final int? distanceMeters;

  /// Null when the image is not available — the tile draws a placeholder.
  final String? imageUrl;

  @override
  List<Object?> get props => [time, distanceMeters, imageUrl];
}

/// The customer's signature on the driver's screen.
class DeliverySignatureEntity extends Equatable {
  const DeliverySignatureEntity({required this.time, this.imageUrl});

  final String time;
  final String? imageUrl;

  @override
  List<Object?> get props => [time, imageUrl];
}

/// A closed stop's log, oldest first, plus any proof of delivery.
class HistoryStopRecordEntity extends Equatable {
  const HistoryStopRecordEntity({
    required this.orderCode,
    required this.events,
    this.photo,
    this.signature,
  });

  final String orderCode;
  final List<StopEventEntity> events;

  /// Proof captured at handover; both null for a stop that failed.
  final DeliveryPhotoEntity? photo;
  final DeliverySignatureEntity? signature;

  bool get hasProof => photo != null || signature != null;

  @override
  List<Object?> get props => [orderCode, events, photo, signature];
}
