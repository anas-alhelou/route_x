// lib/features/orders/presentation/controllers/history_day_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/history_day_stops_entity.dart';

enum HistoryDayStatus { loading, loaded, failed }

class HistoryDayState extends Equatable {
  const HistoryDayState({this.status = HistoryDayStatus.loading, this.data});

  final HistoryDayStatus status;

  /// Present only while [status] is loaded.
  final HistoryDayStopsEntity? data;

  @override
  List<Object?> get props => [status, data];
}
