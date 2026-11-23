// lib/features/orders/data/datasources/history_stop_record_local_data_source.dart
import '../../domain/entities/history_day_stops_entity.dart';
import '../../domain/entities/history_stop_record_entity.dart';
import '../../domain/entities/order_history_entity.dart';

abstract class HistoryStopRecordLocalDataSource {
  Future<HistoryStopRecordEntity> getStopRecord(HistoryStopEntity stop);
}

/// Stand-in for `GET /drivers/me/stops/{order}/events` until the API ships.
///
/// RX-1015 is the designed record, event for event. Every other stop gets a
/// plausible log derived from its own time and outcome, so any row on a day
/// opens onto something consistent with it.
class HistoryStopRecordLocalDataSourceImpl
    implements HistoryStopRecordLocalDataSource {
  const HistoryStopRecordLocalDataSourceImpl({this.loadDelay = Duration.zero});

  final Duration loadDelay;

  static const HistoryStopRecordEntity _rx1015 = HistoryStopRecordEntity(
    orderCode: 'RX-1015',
    events: [
      StopEventEntity(
        kind: StopEventKind.arrived,
        time: '09:44',
        distanceMeters: 12,
      ),
      StopEventEntity(
        kind: StopEventKind.called,
        time: '09:45',
        answered: false,
      ),
      StopEventEntity(
        kind: StopEventKind.calledAgain,
        time: '09:48',
        answered: false,
        waitedMinutes: 5,
      ),
      StopEventEntity(
        kind: StopEventKind.markedFailed,
        time: '09:52',
        reason: DeliveryFailureReason.customerNotAnswering,
      ),
      StopEventEntity(kind: StopEventKind.returnedToDepot, time: '15:20'),
    ],
  );

  /// The designed delivered stop: photo and signature, a call that was
  /// answered, the driver's note on the photo.
  static const HistoryStopRecordEntity _rx1009 = HistoryStopRecordEntity(
    orderCode: 'RX-1009',
    events: [
      StopEventEntity(
        kind: StopEventKind.arrived,
        time: '08:29',
        distanceMeters: 14,
      ),
      StopEventEntity(
        kind: StopEventKind.called,
        time: '08:30',
        answered: true,
      ),
      StopEventEntity(
        kind: StopEventKind.photoTaken,
        time: '08:31',
        note: 'Package at the door, number 12',
      ),
      StopEventEntity(kind: StopEventKind.signed, time: '08:31'),
      StopEventEntity(kind: StopEventKind.delivered, time: '08:31'),
    ],
    photo: DeliveryPhotoEntity(time: '08:31', distanceMeters: 14),
    signature: DeliverySignatureEntity(time: '08:31'),
  );

  @override
  Future<HistoryStopRecordEntity> getStopRecord(HistoryStopEntity stop) async {
    await Future<void>.delayed(loadDelay);
    if (stop.orderCode == _rx1015.orderCode) return _rx1015;
    if (stop.orderCode == _rx1009.orderCode) return _rx1009;

    final arrived = _minus(stop.time, 4);
    if (stop.outcome == HistoryStopOutcome.delivered) {
      return HistoryStopRecordEntity(
        orderCode: stop.orderCode,
        events: [
          StopEventEntity(
            kind: StopEventKind.arrived,
            time: arrived,
            distanceMeters: 8,
          ),
          StopEventEntity(kind: StopEventKind.photoTaken, time: stop.time),
          StopEventEntity(kind: StopEventKind.delivered, time: stop.time),
        ],
        photo: DeliveryPhotoEntity(time: stop.time, distanceMeters: 8),
      );
    }

    // Failed: the attempt, the call, the verdict, the package going back.
    final events = [
      StopEventEntity(
        kind: StopEventKind.arrived,
        time: arrived,
        distanceMeters: 15,
      ),
      StopEventEntity(
        kind: StopEventKind.called,
        time: _minus(stop.time, 2),
        answered: false,
      ),
      StopEventEntity(
        kind: StopEventKind.markedFailed,
        time: stop.time,
        reason: stop.failureReason,
      ),
      const StopEventEntity(kind: StopEventKind.returnedToDepot, time: '15:20'),
    ];
    return HistoryStopRecordEntity(orderCode: stop.orderCode, events: events);
  }

  /// `09:52` minus 4 minutes is `09:48`.
  static String _minus(String clock, int minutes) {
    final parts = clock.split(':');
    final total = int.parse(parts[0]) * 60 + int.parse(parts[1]) - minutes;
    return '${(total ~/ 60).toString().padLeft(2, '0')}:'
        '${(total % 60).toString().padLeft(2, '0')}';
  }
}
