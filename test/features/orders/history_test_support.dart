import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/network/network_info.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_history_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/datasources/sync_queue_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/order_history_repository_impl.dart';
import 'package:routex_mobile/features/orders/data/repositories/sync_queue_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/repositories/order_history_repository.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_order_history_usecase.dart';
import 'package:routex_mobile/features/orders/domain/usecases/sync_queue_usecases.dart';

import 'fake_network_info.dart';

/// The History tab's repository over the mock, online, nothing waiting —
/// or [pendingSync] updates in a fresh queue, or the given [syncQueue].
OrderHistoryRepositoryImpl historyRepository({
  OrderHistoryLocalDataSource source =
      const OrderHistoryLocalDataSourceImpl(loadDelay: Duration.zero),
  NetworkInfo? network,
  int pendingSync = 0,
  SyncQueueLocalDataSource? syncQueue,
  DateTime Function()? clock,
}) =>
    OrderHistoryRepositoryImpl(
      localDataSource: source,
      networkInfo: network ?? FakeNetworkInfo(),
      syncQueue: syncQueue ?? SyncQueueMockDataSource(pending: pendingSync),
      clock: clock,
    );

/// Registers what the History tab resolves from getIt, as the app does:
/// its use case, the network it listens to, and the sync queue's use cases
/// for the screen its sync card opens. Undo with [unregisterHistory].
void registerHistory({
  OrderHistoryRepository? repository,
  FakeNetworkInfo? network,
  SyncQueueLocalDataSource? syncQueue,
}) {
  unregisterHistory();
  final networkInfo = network ?? FakeNetworkInfo();
  final queue = syncQueue ?? SyncQueueMockDataSource(uploadDelay: Duration.zero);
  getIt.registerSingleton<NetworkInfo>(networkInfo);
  getIt.registerLazySingleton<GetOrderHistoryUseCase>(
    () => GetOrderHistoryUseCase(
      repository ??
          historyRepository(network: networkInfo, syncQueue: queue),
    ),
  );
  final syncRepository =
      SyncQueueRepositoryImpl(syncQueue: queue, networkInfo: networkInfo);
  getIt.registerLazySingleton(
    () => GetPendingSyncUpdatesUseCase(syncRepository),
  );
  getIt.registerLazySingleton(() => SyncPendingUpdatesUseCase(syncRepository));
}

void unregisterHistory() {
  if (getIt.isRegistered<GetOrderHistoryUseCase>()) {
    getIt.unregister<GetOrderHistoryUseCase>();
  }
  if (getIt.isRegistered<GetPendingSyncUpdatesUseCase>()) {
    getIt.unregister<GetPendingSyncUpdatesUseCase>();
  }
  if (getIt.isRegistered<SyncPendingUpdatesUseCase>()) {
    getIt.unregister<SyncPendingUpdatesUseCase>();
  }
  if (getIt.isRegistered<NetworkInfo>()) getIt.unregister<NetworkInfo>();
}
