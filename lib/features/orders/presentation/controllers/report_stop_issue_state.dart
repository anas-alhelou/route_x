// lib/features/orders/presentation/controllers/report_stop_issue_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/stop_issue_entity.dart';

enum ReportStopIssueStatus { editing, sending, sent, failed }

class ReportStopIssueState extends Equatable {
  const ReportStopIssueState({
    this.kind,
    this.note = '',
    this.status = ReportStopIssueStatus.editing,
  });

  /// Null until the driver picks a reason.
  final StopIssueKind? kind;

  final String note;
  final ReportStopIssueStatus status;

  bool get isSending => status == ReportStopIssueStatus.sending;

  /// A reason is picked, the note is there if that reason needs one, and
  /// nothing is already on its way.
  bool get canSend {
    final picked = kind;
    if (picked == null || isSending) return false;
    return !StopIssueEntity.needsNote(picked) || note.trim().isNotEmpty;
  }

  ReportStopIssueState copyWith({
    StopIssueKind? kind,
    String? note,
    ReportStopIssueStatus? status,
  }) {
    return ReportStopIssueState(
      kind: kind ?? this.kind,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [kind, note, status];
}
