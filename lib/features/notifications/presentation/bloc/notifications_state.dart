// lib/features/notifications/presentation/bloc/notifications_state.dart
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/features/notifications/domain/entities/app_notification.dart';

/// Status of the Notifications inbox load.
enum NotificationsStatus {
  /// Nothing requested yet — the first frame after [NotificationsPage] is built.
  initial,

  /// First load in flight and no notifications to show yet.
  loading,

  /// Inbox is on screen (may be empty — the Figma Empty variant).
  success,

  /// No inbox could be loaded and [NotificationsState.errorMessage] is set.
  failure,
}

/// Immutable state held by [NotificationsBloc].
class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.isRefreshing = false,
    this.errorMessage,
  });

  /// Current stage of the load.
  final NotificationsStatus status;

  /// Notifications in the inbox (empty in the Figma Empty variant).
  final List<AppNotification> notifications;

  /// A refresh is in flight while content remains on screen.
  final bool isRefreshing;

  /// Non-null only when [status] is [NotificationsStatus.failure] or a refresh
  /// failed while content was already on screen.
  final String? errorMessage;

  /// Whether the inbox is empty after a successful load.
  bool get isEmpty =>
      status == NotificationsStatus.success && notifications.isEmpty;

  /// Number of unread notifications.
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Whether any notification is unread.
  bool get hasUnread => notifications.any((n) => !n.isRead);

  /// [errorMessage] is deliberately not copied forward: it only ever describes
  /// the state being replaced, and silently carrying a stale message through a
  /// successful reload would put an error on screen with nothing wrong.
  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? notifications,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    notifications,
    isRefreshing,
    errorMessage,
  ];
}
