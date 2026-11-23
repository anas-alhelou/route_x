// lib/features/orders/data/repositories/orders_today_repository_impl.dart
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/network/network_info.dart';

import '../../domain/entities/orders_today_snapshot.dart';
import '../../domain/repositories/orders_today_repository.dart';
import '../datasources/orders_today_local_data_source.dart';

/// Serves the live day when it can and the last good one when it cannot.
///
/// A driver loses signal in car parks, basements and between towns — right
/// when they most need their list. Showing the last fetched copy, labelled
/// as such, beats an error screen: the stops rarely change in the minutes
/// the signal is gone.
class OrdersTodayRepositoryImpl implements OrdersTodayRepository {
  OrdersTodayRepositoryImpl({
    required this.localDataSource,
    required this.networkInfo,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final OrdersTodayLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final DateTime Function() _now;

  /// The last successful fetch. In memory only: it outlives navigation
  /// (this repository is a singleton) but not an app restart.
  OrdersTodaySnapshot? _lastGood;

  @override
  Future<OrdersTodaySnapshot> getOrdersToday() async {
    // No link at all: do not wait on a request that cannot succeed.
    if (!await networkInfo.isConnected) {
      return _savedOr(const NetworkFailure(), OfflineReason.noConnection);
    }

    try {
      final data = await localDataSource.getOrdersToday();
      return _lastGood = OrdersTodaySnapshot(data: data, updatedAt: _now());
    } on NetworkFailure catch (failure) {
      // A link that cannot carry the request — a weak signal timing out, or
      // one that dropped mid-flight.
      return _savedOr(failure, OfflineReason.weakSignal);
    }
  }

  OrdersTodaySnapshot _savedOr(NetworkFailure failure, OfflineReason reason) {
    final saved = _lastGood;
    if (saved == null) throw failure;
    return OrdersTodaySnapshot(
      data: saved.data,
      updatedAt: saved.updatedAt,
      offlineReason: reason,
    );
  }
}
