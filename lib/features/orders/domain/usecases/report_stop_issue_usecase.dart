// lib/features/orders/domain/usecases/report_stop_issue_usecase.dart
import '../entities/stop_issue_entity.dart';
import '../repositories/stop_issue_repository.dart';

class ReportStopIssueUseCase {
  const ReportStopIssueUseCase(this._repository);
  final StopIssueRepository _repository;

  /// Rejects a report the screen should never have let through, so the rule
  /// holds even if a future caller skips the screen's check.
  Future<void> call(StopIssueEntity issue) {
    final note = issue.note.trim();
    if (StopIssueEntity.needsNote(issue.kind) && note.isEmpty) {
      throw ArgumentError('A note is required for StopIssueKind.other');
    }
    return _repository.report(
      StopIssueEntity(orderCode: issue.orderCode, kind: issue.kind, note: note),
    );
  }
}
