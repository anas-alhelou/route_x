// lib/features/orders/data/repositories/stop_issue_repository_impl.dart
import '../../domain/entities/stop_issue_entity.dart';
import '../../domain/repositories/stop_issue_repository.dart';
import '../datasources/stop_issue_remote_data_source.dart';

class StopIssueRepositoryImpl implements StopIssueRepository {
  const StopIssueRepositoryImpl({required this.dataSource});

  final StopIssueDataSource dataSource;

  @override
  Future<void> report(StopIssueEntity issue) => dataSource.report(issue);
}
