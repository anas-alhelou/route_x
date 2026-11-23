// lib/features/orders/domain/entities/stop_issue_entity.dart
import 'package:equatable/equatable.dart';

/// What a driver can dispute about a closed stop.
enum StopIssueKind {
  /// Recorded as failed but was delivered, or the other way round.
  statusWrong,

  /// It did fail, but not through the driver's fault — a locked gate, a
  /// closed building. Matters for how the failure counts against them.
  notInMyControl,

  /// The logged arrival or call times do not match what happened.
  timesWrong,

  /// Anything else; only the note can say what.
  other,
}

/// A driver's report about one stop, as sent to dispatch.
class StopIssueEntity extends Equatable {
  const StopIssueEntity({
    required this.orderCode,
    required this.kind,
    this.note = '',
  });

  final String orderCode;
  final StopIssueKind kind;

  /// Free text, trimmed. Required for [StopIssueKind.other], optional
  /// otherwise.
  final String note;

  /// "Something else" with no words says nothing dispatch can act on.
  static bool needsNote(StopIssueKind kind) => kind == StopIssueKind.other;

  @override
  List<Object?> get props => [orderCode, kind, note];
}
