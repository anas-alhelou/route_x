// lib/features/orders/domain/entities/order_history_snapshot.dart
import 'package:equatable/equatable.dart';

import 'order_history_entity.dart';

/// A period's history plus how fresh it is and what this phone has not
/// handed to the server yet.
///
/// Kept apart from [OrderHistoryEntity] for the same reason as the Orders
/// tab's snapshot: freshness is a fact about the fetch, not the history.
class OrderHistorySnapshot extends Equatable {
  const OrderHistorySnapshot({
    required this.data,
    required this.updatedAt,
    this.isFromCache = false,
    this.pendingSyncCount = 0,
  });

  final OrderHistoryEntity data;

  /// When [data] last came from the server. For a saved copy, the time of
  /// the fetch that produced it.
  final DateTime updatedAt;

  /// Served from the copy saved on the phone because the server could not
  /// be reached.
  final bool isFromCache;

  /// Stops finished on this phone and not uploaded yet — counted in [data]
  /// already, so the screen can say the numbers include them.
  final int pendingSyncCount;

  @override
  List<Object?> get props => [data, updatedAt, isFromCache, pendingSyncCount];
}
