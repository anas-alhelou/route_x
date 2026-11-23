// lib/features/orders/data/repositories/sync_queue_repository_impl.dart
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/network/network_info.dart';

import '../../domain/entities/pending_sync_update_entity.dart';
import '../../domain/repositories/sync_queue_repository.dart';
import '../datasources/sync_queue_local_data_source.dart';

class SyncQueueRepositoryImpl implements SyncQueueRepository {
  const SyncQueueRepositoryImpl({
    required this.syncQueue,
    required this.networkInfo,
  });

  final SyncQueueLocalDataSource syncQueue;
  final NetworkInfo networkInfo;

  @override
  Future<List<PendingSyncUpdateEntity>> getPending() =>
      syncQueue.pendingUpdates();

  @override
  Future<void> syncNow() async {
    // No link at all: say so at once rather than after a timeout.
    if (!await networkInfo.isConnected) throw const NetworkFailure();
    await syncQueue.uploadAll();
  }
}
