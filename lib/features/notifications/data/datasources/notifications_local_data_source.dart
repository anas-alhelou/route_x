// lib/features/notifications/data/datasources/notifications_local_data_source.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/notifications/notification_inbox_store.dart';
import 'package:routex_mobile/features/notifications/domain/entities/app_notification.dart';

/// Contract for the local Notifications inbox source.
abstract class NotificationsLocalDataSource {
  Future<Either<Failure, List<AppNotification>>> getNotifications();
  Future<Either<Failure, List<AppNotification>>> markAllRead();
  Future<Either<Failure, List<AppNotification>>> toggleEmptyState();
}

/// Mock implementation providing local notification scenarios:
/// - N01: Populated notifications list (Figma node 6410:55884)
/// - N02: Empty state (Figma node 6410:55949)
class NotificationsLocalDataSourceImpl
    implements NotificationsLocalDataSource {
  /// How long the inbox takes to "arrive".
  final Duration _readDelay;

  /// Design sample rows. The app turns this off: with no notifications
  /// endpoint yet, the inbox must show only the pushes the device received.
  final bool includeSamples;

  /// In-memory notification state.
  late List<AppNotification> _notifications;
  bool _isEmpty = false;

  NotificationsLocalDataSourceImpl({
    Duration readDelay = const Duration(milliseconds: 250),
    this.includeSamples = true,
  }) : _readDelay = readDelay {
    _resetToPopulated();
  }

  void _resetToPopulated() {
    if (!includeSamples) {
      _notifications = [];
      return;
    }
    final now = DateTime.now();
    _notifications = [
      // ── Section 1: "New" (Unread) ──────────────────────────────────────────
      AppNotification(
        id: 'n1',
        title: 'New order offered',
        body: 'Ahmed Ali · Al Rawdah, Jeddah',
        kind: AppNotificationKind.newOrder,
        createdAt: now.subtract(const Duration(minutes: 2)),
        timeLabel: '2m',
        isRead: false,
      ),
      AppNotification(
        id: 'n2',
        title: 'Order cancelled',
        body: 'Red Sea Express cancelled #RX-1035',
        kind: AppNotificationKind.orderCancelled,
        createdAt: now.subtract(const Duration(hours: 1)),
        timeLabel: '1h',
        isRead: false,
      ),

      // ── Section 2: "Earlier" (Read) ────────────────────────────────────────
      AppNotification(
        id: 'n3',
        title: 'Route started',
        body: '2 of 3 orders are on your route. 1 was sent for review.',
        kind: AppNotificationKind.routeStarted,
        createdAt: now.subtract(const Duration(days: 1)),
        timeLabel: 'Yesterday',
        isRead: true,
      ),
      AppNotification(
        id: 'n4',
        title: 'Vehicle updated',
        body: 'Your company set your vehicle to Toyota Hiace · PAL-99488',
        kind: AppNotificationKind.vehicleUpdated,
        createdAt: now.subtract(const Duration(days: 2)),
        timeLabel: '2d',
        isRead: true,
      ),
      AppNotification(
        id: 'n5',
        title: "You're approved",
        body: 'Red Sea Express approved your request. Welcome aboard!',
        kind: AppNotificationKind.fleetApproved,
        createdAt: now.subtract(const Duration(days: 3)),
        timeLabel: '3d',
        isRead: true,
      ),
    ];
  }

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() async {
    if (_readDelay > Duration.zero) {
      await Future<void>.delayed(_readDelay);
    }
    if (_isEmpty) {
      return const Right(<AppNotification>[]);
    }
    return Right(List.unmodifiable([
      ...NotificationInboxStore.instance.items,
      ..._notifications,
    ]));
  }

  @override
  Future<Either<Failure, List<AppNotification>>> markAllRead() async {
    if (_readDelay > Duration.zero) {
      await Future<void>.delayed(_readDelay);
    }
    _notifications = _notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
    NotificationInboxStore.instance.markAllRead();
    return Right(List.unmodifiable([
      ...NotificationInboxStore.instance.items,
      ..._notifications,
    ]));
  }

  @override
  Future<Either<Failure, List<AppNotification>>> toggleEmptyState() async {
    if (_readDelay > Duration.zero) {
      await Future<void>.delayed(_readDelay);
    }
    _isEmpty = !_isEmpty;
    if (!_isEmpty && _notifications.isEmpty) {
      _resetToPopulated();
    }
    if (_isEmpty) {
      return const Right(<AppNotification>[]);
    }
    return Right(List.unmodifiable(_notifications));
  }
}
