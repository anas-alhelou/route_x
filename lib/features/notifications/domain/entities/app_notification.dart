// lib/features/notifications/domain/entities/app_notification.dart
import 'package:equatable/equatable.dart';

/// Kind of notification shown in the Notifications inbox.
enum AppNotificationKind {
  /// New order offered (N01 Section 1 Row 1).
  newOrder,

  /// Order cancelled (N01 Section 1 Row 2).
  orderCancelled,

  /// Route started (N01 Section 2 Row 1).
  routeStarted,

  /// Vehicle updated (N01 Section 2 Row 2).
  vehicleUpdated,

  /// Fleet approval / welcome (N01 Section 2 Row 3).
  fleetApproved,

  /// Route assignment or status change.
  routeUpdate,

  /// Reply from a fleet manager or dispatcher.
  fleetReply,

  /// Direct message from dispatch.
  dispatchMessage,

  /// System / general notification.
  system,
}

/// A single notification as shown in the Notifications inbox.
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    required this.createdAt,
    this.isRead = false,
    this.timeLabel,
  });

  /// Stable identifier.
  final String id;

  /// Short headline shown in the row.
  final String title;

  /// Longer body shown under the headline.
  final String body;

  /// Category used for icon / filtering.
  final AppNotificationKind kind;

  /// When the notification was created.
  final DateTime createdAt;

  /// Whether the user has opened it.
  final bool isRead;

  /// Optional precomputed or localized time label.
  final String? timeLabel;

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    AppNotificationKind? kind,
    DateTime? createdAt,
    bool? isRead,
    String? timeLabel,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      timeLabel: timeLabel ?? this.timeLabel,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    kind,
    createdAt,
    isRead,
    timeLabel,
  ];
}
