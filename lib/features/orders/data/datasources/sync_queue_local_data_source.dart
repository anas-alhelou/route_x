// lib/features/orders/data/datasources/sync_queue_local_data_source.dart
import 'package:routex_mobile/core/errors/failures.dart';

import '../../domain/entities/history_day_stops_entity.dart';
import '../../domain/entities/pending_sync_update_entity.dart';

/// Stop updates — delivered, couldn't deliver, photos — finished on this
/// phone and still waiting to upload. They upload by themselves once a
/// connection holds; "Sync now" only asks for it sooner.
abstract class SyncQueueLocalDataSource {
  /// Oldest first, the order they will upload in.
  Future<List<PendingSyncUpdateEntity>> pendingUpdates();

  Future<int> pendingCount();

  /// Uploads everything queued and empties the queue. Throws a
  /// [NetworkFailure] when the upload does not go through; whatever was
  /// queued stays queued.
  Future<void> uploadAll();
}

/// Stand-in until stops are completed through the app and queued for real.
class SyncQueueMockDataSource implements SyncQueueLocalDataSource {
  SyncQueueMockDataSource({
    int pending = 0,
    this.uploadDelay = const Duration(milliseconds: 800),
    this.uploadFails = false,
  }) : _queue = _fixtures.take(pending).toList();

  final Duration uploadDelay;

  /// Makes [uploadAll] fail as a dropped upload would.
  bool uploadFails;

  final List<PendingSyncUpdateEntity> _queue;

  static const List<PendingSyncUpdateEntity> _fixtures = [
    PendingSyncUpdateEntity(
      id: 'sync-1',
      orderCode: 'RX-1039',
      addressLine: 'Sari St, Al Zahra',
      outcome: HistoryStopOutcome.delivered,
      time: '10:05',
      parts: [PendingSyncPart.photo, PendingSyncPart.status],
    ),
    PendingSyncUpdateEntity(
      id: 'sync-2',
      orderCode: 'RX-1040',
      addressLine: 'Tahlia St, Al Nahda',
      outcome: HistoryStopOutcome.failed,
      time: '10:24',
      parts: [PendingSyncPart.status],
    ),
    PendingSyncUpdateEntity(
      id: 'sync-3',
      orderCode: 'RX-1041',
      addressLine: 'Olaya St, Al Wurud',
      outcome: HistoryStopOutcome.delivered,
      time: '10:48',
      parts: [
        PendingSyncPart.photo,
        PendingSyncPart.signature,
        PendingSyncPart.status,
      ],
    ),
  ];

  @override
  Future<List<PendingSyncUpdateEntity>> pendingUpdates() async =>
      List.unmodifiable(_queue);

  @override
  Future<int> pendingCount() async => _queue.length;

  @override
  Future<void> uploadAll() async {
    await Future<void>.delayed(uploadDelay);
    if (uploadFails) throw const NetworkFailure();
    _queue.clear();
  }
}
