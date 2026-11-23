// lib/features/orders/data/models/orders_today_model.dart
import '../../domain/entities/orders_today_entity.dart';

class TodayStopModel extends TodayStopEntity {
  const TodayStopModel({
    required super.id,
    required super.sequence,
    required super.customerName,
    required super.area,
    required super.timeWindow,
    required super.status,
  });

  factory TodayStopModel.fromJson(Map<String, dynamic> json) {
    return TodayStopModel(
      id: json['id'] as String,
      sequence: (json['sequence'] as num).toInt(),
      customerName: json['customer_name'] as String,
      area: json['area'] as String,
      timeWindow: json['time_window'] as String,
      status: _parseStatus(json['status'] as String?),
    );
  }

  static TodayStopStatus _parseStatus(String? status) {
    switch (status) {
      case 'on_the_way':
        return TodayStopStatus.onTheWay;
      case 'cancelled':
        return TodayStopStatus.cancelled;
      case 'up_next':
      default:
        return TodayStopStatus.upNext;
    }
  }
}

class UpcomingDayModel extends UpcomingDayEntity {
  const UpcomingDayModel({
    required super.id,
    required super.dayLabel,
    required super.dateLabel,
    required super.ordersCount,
    required super.areas,
    super.newOrdersCount,
  });

  factory UpcomingDayModel.fromJson(Map<String, dynamic> json) {
    return UpcomingDayModel(
      id: json['id'] as String,
      dayLabel: json['day_label'] as String? ?? '',
      dateLabel: json['date_label'] as String,
      ordersCount: (json['orders_count'] as num).toInt(),
      areas: List<String>.from(json['areas'] as List? ?? const []),
      newOrdersCount: (json['new_orders_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class OrdersTodayModel extends OrdersTodayEntity {
  const OrdersTodayModel({
    required super.newOrdersCount,
    required super.todayStops,
    required super.remainingCount,
    required super.estimatedFinishTime,
    required super.deliveredTodayCount,
    required super.upcomingDays,
    super.cancellationNotice,
    super.fleetName,
  });

  factory OrdersTodayModel.fromJson(Map<String, dynamic> json) {
    final notice = json['cancellation_notice'] as Map<String, dynamic>?;
    return OrdersTodayModel(
      newOrdersCount: (json['new_orders_count'] as num?)?.toInt() ?? 0,
      todayStops: (json['today_stops'] as List? ?? const [])
          .map((e) => TodayStopModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      remainingCount: (json['remaining_count'] as num?)?.toInt() ?? 0,
      estimatedFinishTime: json['estimated_finish_time'] as String? ?? '',
      deliveredTodayCount: (json['delivered_today_count'] as num?)?.toInt() ?? 0,
      upcomingDays: (json['upcoming_days'] as List? ?? const [])
          .map((e) => UpcomingDayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      cancellationNotice:
          notice == null ? null : CancellationNoticeModel.fromJson(notice),
      fleetName: json['fleet_name'] as String?,
    );
  }
}

class CancellationNoticeModel extends CancellationNoticeEntity {
  const CancellationNoticeModel({
    required super.orderId,
    required super.customerName,
    required super.orderCode,
    required super.cancelledAt,
  });

  factory CancellationNoticeModel.fromJson(Map<String, dynamic> json) {
    return CancellationNoticeModel(
      orderId: json['order_id'] as String,
      customerName: json['customer_name'] as String,
      orderCode: json['order_code'] as String,
      cancelledAt: json['cancelled_at'] as String,
    );
  }
}
