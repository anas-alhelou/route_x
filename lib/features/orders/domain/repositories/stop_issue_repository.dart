// lib/features/orders/domain/repositories/stop_issue_repository.dart
import '../entities/stop_issue_entity.dart';

abstract class StopIssueRepository {
  /// Throws when the report could not be delivered.
  Future<void> report(StopIssueEntity issue);
}
