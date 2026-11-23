// lib/features/notifications/data/repositories/notifications_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/notifications/data/datasources/notifications_local_data_source.dart';
import 'package:routex_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:routex_mobile/features/notifications/domain/repositories/notifications_repository.dart';

/// Delegates to [NotificationsLocalDataSource]; a remote source can replace
/// it without touching callers.
class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl({required this.localDataSource});

  final NotificationsLocalDataSource localDataSource;

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() {
    return localDataSource.getNotifications();
  }

  @override
  Future<Either<Failure, List<AppNotification>>> markAllRead() {
    return localDataSource.markAllRead();
  }

  @override
  Future<Either<Failure, List<AppNotification>>> toggleEmptyState() {
    return localDataSource.toggleEmptyState();
  }
}
