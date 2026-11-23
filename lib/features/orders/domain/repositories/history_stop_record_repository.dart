// lib/features/orders/domain/repositories/history_stop_record_repository.dart
import '../entities/history_day_stops_entity.dart';
import '../entities/history_stop_record_entity.dart';

abstract class HistoryStopRecordRepository {
  Future<HistoryStopRecordEntity> getStopRecord(HistoryStopEntity stop);
}
