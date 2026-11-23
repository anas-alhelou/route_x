// lib/features/notifications/domain/usecases/toggle_notifications_empty_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:routex_mobile/features/notifications/domain/repositories/notifications_repository.dart';

/// Toggles between populated (N01) and empty (N02) scenarios for testing.
class ToggleNotificationsEmptyUseCase
    implements UseCase<List<AppNotification>, NoParams> {
  const ToggleNotificationsEmptyUseCase({required this.repository});

  final NotificationsRepository repository;

  @override
  Future<Either<Failure, List<AppNotification>>> call(NoParams params) {
    return repository.toggleEmptyState();
  }
}
