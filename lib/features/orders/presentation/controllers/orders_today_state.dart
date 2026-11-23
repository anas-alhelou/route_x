// lib/features/orders/presentation/controllers/orders_today_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/orders_today_entity.dart';
import '../../domain/entities/orders_today_snapshot.dart';

abstract class OrdersTodayState extends Equatable {
  const OrdersTodayState({required this.segment});

  /// Carried by every state so switching segments never flashes the header
  /// back to its default while the next payload loads.
  final OrdersTodaySegment segment;

  @override
  List<Object?> get props => [segment];
}

class OrdersTodayInitial extends OrdersTodayState {
  const OrdersTodayInitial({super.segment = OrdersTodaySegment.orders});
}

class OrdersTodayLoading extends OrdersTodayState {
  const OrdersTodayLoading({super.segment = OrdersTodaySegment.orders});
}

class OrdersTodayLoaded extends OrdersTodayState {
  const OrdersTodayLoaded({
    required this.data,
    required this.updatedAt,
    super.segment = OrdersTodaySegment.orders,
    this.acknowledgedNoticeIds = const {},
    this.offline,
    this.arrival,
  });

  final OrdersTodayEntity data;

  /// The latest batch of orders that came in on a refresh, for the toast.
  /// Kept on later states unchanged; the toast shows each [OrdersArrival.id]
  /// once, so carrying it along never re-announces it.
  final OrdersArrival? arrival;

  /// When [data] last came from the server.
  final DateTime updatedAt;

  /// Null while live. Otherwise the list is the saved copy and may be out of
  /// date, and this says why — which decides how the screen says so.
  final OfflineReason? offline;

  bool get isOffline => offline != null;

  /// The banner slot is taken by the connection card; the cancellation and
  /// new-orders banners wait until it clears.
  bool get isDisconnected => offline == OfflineReason.noConnection;

  /// Order ids whose cancellation the driver has already tapped OK on.
  final Set<String> acknowledgedNoticeIds;

  /// The cancellation notice to show, or null once it has been acknowledged.
  CancellationNoticeEntity? get visibleNotice {
    final notice = data.cancellationNotice;
    if (notice == null || acknowledgedNoticeIds.contains(notice.orderId)) {
      return null;
    }
    return notice;
  }

  /// [offline] is wrapped in a function so a caller can set it back to null
  /// (live) — a plain nullable parameter could not tell "clear it" from
  /// "leave it".
  OrdersTodayLoaded copyWith({
    OrdersTodayEntity? data,
    DateTime? updatedAt,
    OrdersTodaySegment? segment,
    Set<String>? acknowledgedNoticeIds,
    OfflineReason? Function()? offline,
  }) {
    return OrdersTodayLoaded(
      data: data ?? this.data,
      updatedAt: updatedAt ?? this.updatedAt,
      segment: segment ?? this.segment,
      acknowledgedNoticeIds:
          acknowledgedNoticeIds ?? this.acknowledgedNoticeIds,
      offline: offline != null ? offline() : this.offline,
      arrival: arrival,
    );
  }

  @override
  List<Object?> get props =>
      [data, updatedAt, segment, acknowledgedNoticeIds, offline, arrival];
}

/// Orders that appeared between one fetch and the next — "2 orders added to
/// tomorrow".
class OrdersArrival extends Equatable {
  const OrdersArrival({
    required this.id,
    required this.count,
    this.dayName,
  });

  /// Unique per arrival, so the toast can tell a new batch from the same one
  /// carried along on a later state.
  final int id;

  final int count;

  /// The one day they all landed on, as it reads in a sentence
  /// (`tomorrow`). Null when they spread over several days.
  final String? dayName;

  @override
  List<Object?> get props => [id, count, dayName];
}

class OrdersTodayError extends OrdersTodayState {
  const OrdersTodayError(
    this.messageKey, {
    super.segment = OrdersTodaySegment.orders,
  });

  /// A key for `context.translateValidationKey`, not finished copy — the
  /// cubit has no BuildContext to localize with.
  final String messageKey;

  @override
  List<Object?> get props => [messageKey, segment];
}
