// lib/features/orders/presentation/pages/history_issue_sent_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/di/injection.dart';

import '../../domain/entities/history_day_stops_entity.dart';
import '../controllers/history_stop_record_cubit.dart';
import 'history_stop_record_page.dart';

/// A stop's record straight after the driver reported it: the outcome is
/// flagged, a note says where dispatch's answer will arrive, and a toast
/// confirms the send.
///
/// The same record view as [HistoryStopRecordPage], in its issue-sent state
/// — one screen with two moments, not two screens kept in step. It replaces
/// the record on the stack, so Back returns to the day.
class HistoryIssueSentPage extends StatelessWidget {
  const HistoryIssueSentPage({
    super.key,
    required this.stop,
    required this.dayLabel,
    required this.totalStops,
  });

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
        issueSent: true,
      ),
    );
  }
}
