// lib/features/orders/presentation/controllers/waiting_to_sync_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pending_sync_update_entity.dart';
import '../../domain/usecases/sync_queue_usecases.dart';

enum WaitingToSyncStatus { loading, loaded, failed }

class WaitingToSyncState extends Equatable {
  const WaitingToSyncState({
    this.status = WaitingToSyncStatus.loading,
    this.updates = const [],
    this.syncing = false,
    this.syncFailed = false,
  });

  final WaitingToSyncStatus status;
  final List<PendingSyncUpdateEntity> updates;

  /// "Sync now" is uploading.
  final bool syncing;

  /// The last "Sync now" did not go through — no signal, or it dropped.
  /// Cleared by the next attempt.
  final bool syncFailed;

  /// Everything went up: the queue is empty.
  bool get isEmpty => status == WaitingToSyncStatus.loaded && updates.isEmpty;

  WaitingToSyncState copyWith({
    WaitingToSyncStatus? status,
    List<PendingSyncUpdateEntity>? updates,
    bool? syncing,
    bool? syncFailed,
  }) =>
      WaitingToSyncState(
        status: status ?? this.status,
        updates: updates ?? this.updates,
        syncing: syncing ?? this.syncing,
        syncFailed: syncFailed ?? this.syncFailed,
      );

  @override
  List<Object?> get props => [status, updates, syncing, syncFailed];
}

class WaitingToSyncCubit extends Cubit<WaitingToSyncState> {
  WaitingToSyncCubit({
    required GetPendingSyncUpdatesUseCase getPendingSyncUpdatesUseCase,
    required SyncPendingUpdatesUseCase syncPendingUpdatesUseCase,
  })  : _getPending = getPendingSyncUpdatesUseCase,
        _syncNow = syncPendingUpdatesUseCase,
        super(const WaitingToSyncState());

  final GetPendingSyncUpdatesUseCase _getPending;
  final SyncPendingUpdatesUseCase _syncNow;

  Future<void> load() async {
    try {
      final updates = await _getPending();
      if (isClosed) return;
      emit(WaitingToSyncState(
        status: WaitingToSyncStatus.loaded,
        updates: updates,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(const WaitingToSyncState(status: WaitingToSyncStatus.failed));
    }
  }

  Future<void> syncNow() async {
    if (state.syncing) return;
    emit(state.copyWith(syncing: true, syncFailed: false));
    try {
      await _syncNow();
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(syncing: false, syncFailed: true));
      return;
    }
    if (isClosed) return;
    // Read the queue back rather than assume it emptied: anything finished
    // while the upload ran is still waiting.
    final updates = await _getPending();
    if (isClosed) return;
    emit(state.copyWith(updates: updates, syncing: false));
  }
}
