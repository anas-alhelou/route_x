// lib/features/orders/domain/entities/orders_today_snapshot.dart
import 'package:equatable/equatable.dart';

import 'orders_today_entity.dart';

/// Why the day on screen is the saved copy rather than a live one. The two
/// call for different things from the driver, so the screen tells them apart.
enum OfflineReason {
  /// No Wi-Fi or mobile link at all. Nothing will load until one returns,
  /// so the screen says so plainly and offers a manual retry.
  noConnection,

  /// A link exists but the request did not make it — a weak or fading
  /// signal. The app keeps retrying by itself; the screen only notes how old
  /// the copy is.
  weakSignal,
}

/// A day's orders plus how fresh they are.
///
/// Kept apart from [OrdersTodayEntity] because freshness is a fact about
/// the fetch, not the schedule: the same day can arrive live one minute and
/// from the saved copy the next.
class OrdersTodaySnapshot extends Equatable {
  const OrdersTodaySnapshot({
    required this.data,
    required this.updatedAt,
    this.offlineReason,
  });

  final OrdersTodayEntity data;

  /// When [data] last came from the server. For a saved copy this is the
  /// time of the fetch that produced it, not the time it was read back.
  final DateTime updatedAt;

  /// Null for a live fetch; otherwise why the saved copy was served.
  final OfflineReason? offlineReason;

  bool get isFromCache => offlineReason != null;

  @override
  List<Object?> get props => [data, updatedAt, offlineReason];
}
