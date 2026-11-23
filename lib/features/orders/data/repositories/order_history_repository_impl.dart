// lib/features/orders/data/repositories/order_history_repository_impl.dart
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/network/network_info.dart';

import '../../domain/entities/order_history_entity.dart';
import '../../domain/entities/order_history_snapshot.dart';
import '../../domain/repositories/order_history_repository.dart';
import '../datasources/order_history_local_data_source.dart';
import '../datasources/sync_queue_local_data_source.dart';

/// Serves the live history when it can and the last good copy of the same
/// period when it cannot — the Orders tab's rule, applied per period: a
/// week seen once stays readable in a car park.
class OrderHistoryRepositoryImpl implements OrderHistoryRepository {
  OrderHistoryRepositoryImpl({
    required this.localDataSource,
    required this.networkInfo,
    required this.syncQueue,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final OrderHistoryLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final SyncQueueLocalDataSource syncQueue;
  final DateTime Function() _now;

  /// The last successful fetch of each period. In memory only: it outlives
  /// navigation (this repository is a singleton) but not an app restart.
  final Map<HistoryPeriod, OrderHistorySnapshot> _lastGood = {};

  @override
  Future<OrderHistorySnapshot> getHistory(HistoryPeriod period) async {
    final pending = await syncQueue.pendingCount();

    // No link at all: do not wait on a request that cannot succeed.
    if (!await networkInfo.isConnected) {
      return _savedOr(period, pending, const NetworkFailure());
    }

    try {
      final data = await localDataSource.getHistory(period);
      return _lastGood[period] = OrderHistorySnapshot(
        data: data,
        updatedAt: _now(),
        pendingSyncCount: pending,
      );
    } on NetworkFailure catch (failure) {
      return _savedOr(period, pending, failure);
    }
  }

  OrderHistorySnapshot _savedOr(
    HistoryPeriod period,
    int pending,
    NetworkFailure failure,
  ) {
    final saved = _lastGood[period];
    if (saved == null) throw failure;
    return OrderHistorySnapshot(
      data: saved.data,
      updatedAt: saved.updatedAt,
      isFromCache: true,
      // The queue is read now, not taken from the copy: stops finished
      // since the copy was saved are waiting too.
      pendingSyncCount: pending,
    );
  }
}
