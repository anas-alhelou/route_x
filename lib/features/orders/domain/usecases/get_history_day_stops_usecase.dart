// lib/features/orders/domain/usecases/get_history_day_stops_usecase.dart
import '../entities/history_day_stops_entity.dart';
import '../repositories/history_day_repository.dart';

class GetHistoryDayStopsUseCase {
  const GetHistoryDayStopsUseCase(this._repository);
  final HistoryDayRepository _repository;

  Future<HistoryDayStopsEntity> call(String dayId) =>
      _repository.getDayStops(dayId);
}
