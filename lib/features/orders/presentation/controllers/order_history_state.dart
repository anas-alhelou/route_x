// lib/features/orders/presentation/controllers/order_history_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/order_history_entity.dart';

enum OrderHistoryStatus { loading, loaded, failed }

class OrderHistoryState extends Equatable {
  const OrderHistoryState({
    this.period = HistoryPeriod.week,
    this.status = OrderHistoryStatus.loading,
    this.data,
    this.updatedAt,
    this.isOffline = false,
    this.pendingSyncCount = 0,
    this.refreshing = false,
  });

  /// Carried through loading so the chips never jump back while the next
  /// period loads.
  final HistoryPeriod period;

  final OrderHistoryStatus status;

  /// Present only while [status] is loaded.
  final OrderHistoryEntity? data;

  /// When [data] last came from the server; null until loaded.
  final DateTime? updatedAt;

  /// [data] is the copy saved on the phone; the server could not be
  /// reached.
  final bool isOffline;

  /// Stop updates on this phone still waiting to upload.
  final int pendingSyncCount;

  /// Fetching again in place, over what is on screen — Retry on a summary
  /// that did not load, or the network coming back.
  final bool refreshing;

  OrderHistoryState copyWith({bool? refreshing}) => OrderHistoryState(
    period: period,
    status: status,
    data: data,
    updatedAt: updatedAt,
    isOffline: isOffline,
    pendingSyncCount: pendingSyncCount,
    refreshing: refreshing ?? this.refreshing,
  );

  @override
  List<Object?> get props => [
    period,
    status,
    data,
    updatedAt,
    isOffline,
    pendingSyncCount,
    refreshing,
  ];
}
