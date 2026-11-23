// lib/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:routex_mobile/features/notifications/domain/repositories/notifications_repository.dart';

/// Marks all notifications in the inbox as read (Single Responsibility Principle).
class MarkAllNotificationsReadUseCase
    implements UseCase<List<AppNotification>, NoParams> {
  const MarkAllNotificationsReadUseCase({required this.repository});

  final NotificationsRepository repository;

  @override
  Future<Either<Failure, List<AppNotification>>> call(NoParams params) {
    return repository.markAllRead();
  }
}
