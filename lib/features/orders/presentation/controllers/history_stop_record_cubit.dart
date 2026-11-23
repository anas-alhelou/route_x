// lib/features/orders/presentation/controllers/history_stop_record_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/history_day_stops_entity.dart';
import '../../domain/usecases/get_history_stop_record_usecase.dart';
import 'history_stop_record_state.dart';

class HistoryStopRecordCubit extends Cubit<HistoryStopRecordState> {
  HistoryStopRecordCubit({
    required GetHistoryStopRecordUseCase getHistoryStopRecordUseCase,
    required this.stop,
  })  : _getRecord = getHistoryStopRecordUseCase,
        super(const HistoryStopRecordState());

  final GetHistoryStopRecordUseCase _getRecord;
  final HistoryStopEntity stop;

  /// Only the newest load may land, so a Try again that overtakes a slow
  /// first attempt is the answer that stays.
  int _generation = 0;

  Future<void> load() async {
    final generation = ++_generation;
    emit(const HistoryStopRecordState());
    try {
      final record = await _getRecord(stop);
      if (isClosed || generation != _generation) return;
      emit(
        HistoryStopRecordState(
          status: HistoryStopRecordStatus.loaded,
          record: record,
        ),
      );
    } catch (_) {
      if (isClosed || generation != _generation) return;
      emit(
        const HistoryStopRecordState(status: HistoryStopRecordStatus.failed),
      );
    }
  }
}
