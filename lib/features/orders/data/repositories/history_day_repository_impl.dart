// lib/features/orders/data/repositories/history_day_repository_impl.dart
import '../../domain/entities/history_day_stops_entity.dart';
import '../../domain/repositories/history_day_repository.dart';
import '../datasources/history_day_local_data_source.dart';

class HistoryDayRepositoryImpl implements HistoryDayRepository {
  const HistoryDayRepositoryImpl({required this.localDataSource});

  final HistoryDayLocalDataSource localDataSource;

  @override
  Future<HistoryDayStopsEntity> getDayStops(String dayId) =>
      localDataSource.getDayStops(dayId);
}
