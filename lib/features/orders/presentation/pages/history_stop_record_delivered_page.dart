// lib/features/orders/presentation/pages/history_stop_record_delivered_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/di/injection.dart';

import '../../domain/entities/history_day_stops_entity.dart';
import '../controllers/history_stop_record_cubit.dart';
import 'history_stop_record_page.dart';

/// The record of a delivered stop: who took it, the photo and signature
/// that prove it, and the log of how it went.
///
/// The same record view as a failed stop's — the outcome decides the
/// colours, the proof card and the timeline's events — opened from the day
/// for every stop that was delivered.
class HistoryStopRecordDeliveredPage extends StatelessWidget {
  HistoryStopRecordDeliveredPage({
    super.key,
    required this.stop,
    required this.dayLabel,
    required this.totalStops,
  }) : assert(
          stop.outcome == HistoryStopOutcome.delivered,
          'Only delivered stops open this page',
        );

  final HistoryStopEntity stop;
  final String dayLabel;
  final int totalStops;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryStopRecordCubit(
        getHistoryStopRecordUseCase: getIt(),
        stop: stop,
      )..load(),
      child: HistoryStopRecordView(
        stop: stop,
        dayLabel: dayLabel,
        totalStops: totalStops,
      ),
    );
  }
}
