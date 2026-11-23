// lib/features/orders/presentation/controllers/report_stop_issue_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/stop_issue_entity.dart';
import '../../domain/usecases/report_stop_issue_usecase.dart';
import 'report_stop_issue_state.dart';

class ReportStopIssueCubit extends Cubit<ReportStopIssueState> {
  ReportStopIssueCubit({
    required ReportStopIssueUseCase reportStopIssueUseCase,
    required this.orderCode,
  })  : _report = reportStopIssueUseCase,
        super(const ReportStopIssueState());

  final ReportStopIssueUseCase _report;
  final String orderCode;

  void select(StopIssueKind kind) {
    if (state.isSending) return;
    // Picking again after a failure is the driver retrying; clear the error.
    emit(state.copyWith(kind: kind, status: ReportStopIssueStatus.editing));
  }

  void noteChanged(String note) {
    if (state.isSending) return;
    emit(state.copyWith(note: note, status: ReportStopIssueStatus.editing));
  }

  Future<void> send() async {
    final kind = state.kind;
    if (!state.canSend || kind == null) return;

    emit(state.copyWith(status: ReportStopIssueStatus.sending));
    try {
      await _report(
        StopIssueEntity(orderCode: orderCode, kind: kind, note: state.note),
      );
      if (isClosed) return;
      emit(state.copyWith(status: ReportStopIssueStatus.sent));
    } catch (_) {
      if (isClosed) return;
      // The choice and the note stay; only the attempt failed.
      emit(state.copyWith(status: ReportStopIssueStatus.failed));
    }
  }
}
