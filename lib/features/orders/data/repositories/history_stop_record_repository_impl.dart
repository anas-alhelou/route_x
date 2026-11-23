// lib/features/orders/data/repositories/history_stop_record_repository_impl.dart
import '../../domain/entities/history_day_stops_entity.dart';
import '../../domain/entities/history_stop_record_entity.dart';
import '../../domain/repositories/history_stop_record_repository.dart';
import '../datasources/history_stop_record_local_data_source.dart';

class HistoryStopRecordRepositoryImpl implements HistoryStopRecordRepository {
  const HistoryStopRecordRepositoryImpl({required this.localDataSource});

  final HistoryStopRecordLocalDataSource localDataSource;

  @override
  Future<HistoryStopRecordEntity> getStopRecord(HistoryStopEntity stop) =>
      localDataSource.getStopRecord(stop);
}
