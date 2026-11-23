// lib/features/orders/data/datasources/history_day_local_data_source.dart
import '../../domain/entities/history_day_stops_entity.dart';
import '../../domain/entities/order_history_entity.dart';

abstract class HistoryDayLocalDataSource {
  /// Throws a [StateError] for a day it knows nothing about.
  Future<HistoryDayStopsEntity> getDayStops(String dayId);
}

/// Stand-in for `GET /drivers/me/history/days/{id}` until the API ships.
///
/// Saturday is the designed day, stop for stop. The other working days of
/// the mock week are generated from their counts, so every row on the
/// History tab opens onto something consistent with what it showed.
class HistoryDayLocalDataSourceImpl implements HistoryDayLocalDataSource {
  const HistoryDayLocalDataSourceImpl({this.loadDelay = Duration.zero});

  final Duration loadDelay;

  static const HistoryDayStopsEntity _saturday = HistoryDayStopsEntity(
    dayId: '2025-10-10',
    shiftStart: '08:05',
    shiftEnd: '12:10',
    stops: [
      HistoryStopEntity(
        sequence: 1,
        addressLine: 'Sari St, Al Zahra',
        orderCode: 'RX-1009',
        time: '08:31',
        outcome: HistoryStopOutcome.delivered,
        handover: HandoverKind.customerAtDoor,
      ),
      HistoryStopEntity(
        sequence: 2,
        addressLine: 'Al Madinah Rd, Al Nahda',
        orderCode: 'RX-1011',
        time: '08:58',
        outcome: HistoryStopOutcome.delivered,
        handover: HandoverKind.reception,
      ),
      HistoryStopEntity(
        sequence: 3,
        addressLine: 'Palestine St, Al Salamah',
        orderCode: 'RX-1012',
        time: '09:20',
        outcome: HistoryStopOutcome.delivered,
        handover: HandoverKind.customerAtDoor,
      ),
      HistoryStopEntity(
        sequence: 4,
        addressLine: 'Tahlia St, Al Nahda',
        orderCode: 'RX-1015',
        time: '09:52',
        outcome: HistoryStopOutcome.failed,
        failureReason: DeliveryFailureReason.customerNotAnswering,
        inReview: true,
      ),
      HistoryStopEntity(
        sequence: 5,
        addressLine: 'Quraish St, Al Salamah',
        orderCode: 'RX-1017',
        time: '10:24',
        outcome: HistoryStopOutcome.delivered,
        handover: HandoverKind.customerAtDoor,
      ),
      HistoryStopEntity(
        sequence: 6,
        addressLine: 'Prince Sultan St, Al Rawdah',
        orderCode: 'RX-1018',
        time: '10:51',
        outcome: HistoryStopOutcome.delivered,
        handover: HandoverKind.guard,
      ),
      HistoryStopEntity(
        sequence: 7,
        addressLine: 'Al Rawdah St 9',
        orderCode: 'RX-1020',
        time: '11:30',
        outcome: HistoryStopOutcome.delivered,
        handover: HandoverKind.customerAtDoor,
      ),
      HistoryStopEntity(
        sequence: 8,
        addressLine: 'Hira St, Al Rawdah',
        orderCode: 'RX-1021',
        time: '12:02',
        outcome: HistoryStopOutcome.delivered,
        handover: HandoverKind.customerAtDoor,
      ),
    ],
  );

  /// Delivered and failed counts for the generated days, matching the
  /// History tab's rows. A failed stop, if any, sits second to last.
  static const Map<String, (int delivered, int failed, int firstCode)> _plan = {
    '2025-10-11': (2, 0, 1101),
    '2025-10-08': (4, 0, 980),
    '2025-10-07': (7, 1, 950),
    '2025-10-06': (5, 0, 930),
    '2025-10-05': (6, 0, 910),
  };

  static const List<String> _streets = [
    'Olaya St, Al Olaya',
    'King Fahd Rd, Al Malaz',
    'Tahlia St, Al Nahda',
    'Al Imam Saud Rd, Al Rawdah',
    'Prince Sultan St, Al Rawdah',
    'Al Salamah St, Al Salamah',
    'Hira St, Al Zahra',
    'Palestine St, Al Salamah',
  ];

  @override
  Future<HistoryDayStopsEntity> getDayStops(String dayId) async {
    await Future<void>.delayed(loadDelay);
    if (dayId == _saturday.dayId) return _saturday;

    final plan = _plan[dayId];
    if (plan == null) throw StateError('No stops for $dayId');
    final (delivered, failed, firstCode) = plan;
    final total = delivered + failed;

    String clock(int minutes) =>
        '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
        '${(minutes % 60).toString().padLeft(2, '0')}';

    const start = 8 * 60 + 10;
    return HistoryDayStopsEntity(
      dayId: dayId,
      shiftStart: clock(start - 5),
      shiftEnd: clock(start + total * 28 + 10),
      stops: [
        for (var i = 0; i < total; i++)
          HistoryStopEntity(
            sequence: i + 1,
            addressLine: _streets[i % _streets.length],
            orderCode: 'RX-${firstCode + i * 2}',
            time: clock(start + (i + 1) * 28),
            outcome: failed > 0 && i == total - 2
                ? HistoryStopOutcome.failed
                : HistoryStopOutcome.delivered,
            failureReason: failed > 0 && i == total - 2
                ? DeliveryFailureReason.addressNotFound
                : null,
            handover: failed > 0 && i == total - 2
                ? null
                : HandoverKind.customerAtDoor,
          ),
      ],
    );
  }
}
