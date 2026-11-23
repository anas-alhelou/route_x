// lib/features/orders/domain/repositories/sync_queue_repository.dart
import '../entities/pending_sync_update_entity.dart';

abstract class SyncQueueRepository {
  Future<List<PendingSyncUpdateEntity>> getPending();

  /// Uploads the queue now. Throws a `NetworkFailure` when there is no
  /// signal or the upload drops; the queue is kept either way until it
  /// goes through.
  Future<void> syncNow();
}
