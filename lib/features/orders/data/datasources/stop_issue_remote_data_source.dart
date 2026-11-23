// lib/features/orders/data/datasources/stop_issue_remote_data_source.dart
import '../../domain/entities/stop_issue_entity.dart';

abstract class StopIssueDataSource {
  Future<void> report(StopIssueEntity issue);
}

/// Stand-in for `POST /drivers/me/stops/{order}/issues` until the API
/// ships: waits as a request would, then succeeds.
class StopIssueMockDataSource implements StopIssueDataSource {
  const StopIssueMockDataSource({
    this.delay = const Duration(milliseconds: 800),
  });

  final Duration delay;

  @override
  Future<void> report(StopIssueEntity issue) =>
      Future<void>.delayed(delay);
}
