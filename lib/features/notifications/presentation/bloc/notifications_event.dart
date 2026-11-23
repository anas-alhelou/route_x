// lib/features/notifications/presentation/bloc/notifications_event.dart
import 'package:equatable/equatable.dart';

/// Events handled by [NotificationsBloc].
sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

/// First load when the page is opened.
class NotificationsStarted extends NotificationsEvent {
  const NotificationsStarted();
}

/// Pull-to-refresh while content is already on screen.
class NotificationsRefreshed extends NotificationsEvent {
  const NotificationsRefreshed();
}

/// Marks all unread notifications as read.
class NotificationsMarkAllRead extends NotificationsEvent {
  const NotificationsMarkAllRead();
}

/// Toggles between populated (N01) and empty (N02) inbox state for testing.
class NotificationsToggleEmpty extends NotificationsEvent {
  const NotificationsToggleEmpty();
}

/// Dismisses the error banner / dialog without retrying.
class NotificationsErrorDismissed extends NotificationsEvent {
  const NotificationsErrorDismissed();
}
