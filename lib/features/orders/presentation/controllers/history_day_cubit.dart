// lib/features/orders/presentation/controllers/history_day_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_history_day_stops_usecase.dart';
import 'history_day_state.dart';

class HistoryDayCubit extends Cubit<HistoryDayState> {
  HistoryDayCubit({
    required GetHistoryDayStopsUseCase getHistoryDayStopsUseCase,
    required this.dayId,
  })  : _getStops = getHistoryDayStopsUseCase,
        super(const HistoryDayState());

  final GetHistoryDayStopsUseCase _getStops;
  final String dayId;

  /// Bumped on every load, so a Try again that overtakes a slow first
  /// attempt is the one whose answer stays on screen.
  int _generation = 0;

  Future<void> load() async {
    final generation = ++_generation;
    emit(const HistoryDayState());
    try {
      final data = await _getStops(dayId);
      if (isClosed || generation != _generation) return;
      emit(HistoryDayState(status: HistoryDayStatus.loaded, data: data));
    } catch (_) {
      if (isClosed || generation != _generation) return;
      emit(const HistoryDayState(status: HistoryDayStatus.failed));
    }
  }
}
