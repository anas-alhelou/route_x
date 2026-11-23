// lib/features/orders/domain/usecases/get_history_stop_record_usecase.dart
import '../entities/history_day_stops_entity.dart';
import '../entities/history_stop_record_entity.dart';
import '../repositories/history_stop_record_repository.dart';

class GetHistoryStopRecordUseCase {
  const GetHistoryStopRecordUseCase(this._repository);
  final HistoryStopRecordRepository _repository;

  Future<HistoryStopRecordEntity> call(HistoryStopEntity stop) =>
      _repository.getStopRecord(stop);
}
