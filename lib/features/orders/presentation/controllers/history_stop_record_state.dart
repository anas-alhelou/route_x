// lib/features/orders/presentation/controllers/history_stop_record_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/history_stop_record_entity.dart';

enum HistoryStopRecordStatus { loading, loaded, failed }

class HistoryStopRecordState extends Equatable {
  const HistoryStopRecordState({
    this.status = HistoryStopRecordStatus.loading,
    this.record,
  });

  final HistoryStopRecordStatus status;

  /// Present only while [status] is loaded.
  final HistoryStopRecordEntity? record;

  @override
  List<Object?> get props => [status, record];
}
