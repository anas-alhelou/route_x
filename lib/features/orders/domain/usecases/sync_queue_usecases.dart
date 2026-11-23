// lib/features/orders/domain/usecases/sync_queue_usecases.dart
import '../entities/pending_sync_update_entity.dart';
import '../repositories/sync_queue_repository.dart';

class GetPendingSyncUpdatesUseCase {
  const GetPendingSyncUpdatesUseCase(this._repository);
  final SyncQueueRepository _repository;

  Future<List<PendingSyncUpdateEntity>> call() => _repository.getPending();
}

class SyncPendingUpdatesUseCase {
  const SyncPendingUpdatesUseCase(this._repository);
  final SyncQueueRepository _repository;

  Future<void> call() => _repository.syncNow();
}
