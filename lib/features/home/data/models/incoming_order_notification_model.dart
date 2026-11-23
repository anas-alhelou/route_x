// lib/features/home/data/models/incoming_order_notification_model.dart
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';

class IncomingOrderNotificationModel extends IncomingOrderNotification {
  const IncomingOrderNotificationModel({
    required super.id,
    required super.title,
    required super.timeAgo,
    required super.subtitle,
    super.orderId,
  });

  factory IncomingOrderNotificationModel.fromJson(Map<String, dynamic> json) {
    return IncomingOrderNotificationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'New order offered',
      timeAgo: json['timeAgo'] as String? ?? 'now',
      subtitle: json['subtitle'] as String? ?? '',
      orderId: json['orderId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'timeAgo': timeAgo,
      'subtitle': subtitle,
      if (orderId != null) 'orderId': orderId,
    };
  }

  IncomingOrderNotification toEntity() => IncomingOrderNotification(
        id: id,
        title: title,
        timeAgo: timeAgo,
        subtitle: subtitle,
        orderId: orderId,
      );
}
