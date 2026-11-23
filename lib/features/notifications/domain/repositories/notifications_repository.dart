// lib/features/notifications/domain/repositories/notifications_repository.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/notifications/domain/entities/app_notification.dart';

/// Abstract definition of the Notifications inbox data operations.
///
/// Every method returns `Either<Failure, T>` so the Bloc and tests exercise
/// the same contract a future remote implementation will honour.
abstract class NotificationsRepository {
  /// Loads the inbox.
  Future<Either<Failure, List<AppNotification>>> getNotifications();

  /// Marks all unread notifications in the inbox as read.
  Future<Either<Failure, List<AppNotification>>> markAllRead();

  /// Toggles between populated (N01) and empty (N02) inbox state for testing.
  Future<Either<Failure, List<AppNotification>>> toggleEmptyState();
}
