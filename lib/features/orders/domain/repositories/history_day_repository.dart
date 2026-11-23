// lib/features/orders/domain/repositories/history_day_repository.dart
import '../entities/history_day_stops_entity.dart';

abstract class HistoryDayRepository {
  Future<HistoryDayStopsEntity> getDayStops(String dayId);
}
