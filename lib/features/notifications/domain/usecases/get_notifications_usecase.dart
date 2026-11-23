// lib/features/notifications/domain/usecases/get_notifications_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:routex_mobile/features/notifications/domain/repositories/notifications_repository.dart';

/// Loads the Notifications inbox (Single Responsibility Principle).
///
/// Takes no parameters — the inbox is the same for the current driver — so
/// [NoParams] keeps it on the same shape as every other use case.
class GetNotificationsUseCase
    implements UseCase<List<AppNotification>, NoParams> {
  const GetNotificationsUseCase({required this.repository});

  final NotificationsRepository repository;

  @override
  Future<Either<Failure, List<AppNotification>>> call(NoParams params) {
    return repository.getNotifications();
  }
}
