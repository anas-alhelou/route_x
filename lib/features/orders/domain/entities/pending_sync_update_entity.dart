// lib/features/orders/domain/entities/pending_sync_update_entity.dart
import 'package:equatable/equatable.dart';

import 'history_day_stops_entity.dart';

/// What a queued update carries — listed on the row so the driver knows a
/// photo is among what would be lost.
enum PendingSyncPart { photo, signature, status }

/// One stop finished on this phone and not uploaded yet.
class PendingSyncUpdateEntity extends Equatable {
  const PendingSyncUpdateEntity({
    required this.id,
    required this.orderCode,
    required this.addressLine,
    required this.outcome,
    required this.time,
    required this.parts,
  });

  final String id;

  /// `RX-1039`, without the `#`.
  final String orderCode;

  final String addressLine;
  final HistoryStopOutcome outcome;

  /// When the stop was closed, `10:05`.
  final String time;

  /// In upload order; never empty — every update has at least its status.
  final List<PendingSyncPart> parts;

  @override
  List<Object?> get props => [id, orderCode, addressLine, outcome, time, parts];
}
