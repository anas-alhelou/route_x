// lib/core/notifications/notification_inbox_store.dart
import 'package:routex_mobile/core/notifications/notification_preferences.dart';
import 'package:routex_mobile/features/notifications/domain/entities/app_notification.dart';

/// Notifications received while the app runs (or reached it through a push).
/// The Notifications inbox (N01) shows them above its other rows.
class NotificationInboxStore {
  NotificationInboxStore._();

  static final NotificationInboxStore instance = NotificationInboxStore._();

  final List<AppNotification> _items = [];

  List<AppNotification> get items => List.unmodifiable(_items);

  void add({
    required String id,
    required String title,
    required String body,
    required AppNotificationKind kind,
  }) {
    if (_items.any((n) => n.id == id)) return;
    _items.insert(
      0,
      AppNotification(
        id: id,
        title: title,
        body: body,
        kind: kind,
        createdAt: DateTime.now(),
        timeLabel: 'now',
      ),
    );
    NotificationInboxBadge.unread.value++;
  }

  void markAllRead() {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
  }
}
