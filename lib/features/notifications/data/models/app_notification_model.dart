// lib/features/notifications/data/models/app_notification_model.dart
import 'package:routex_mobile/features/notifications/domain/entities/app_notification.dart';

/// Data-layer representation of [AppNotification].
///
/// Extends the entity so the repository can return `List<AppNotification>`
/// without mapping, while keeping a `fromJson` hook for a future remote source.
class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.kind,
    required super.createdAt,
    super.isRead,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      kind: AppNotificationKind.values.firstWhere(
        (k) => k.name == json['kind'],
        orElse: () => AppNotificationKind.system,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'kind': kind.name,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };
}
