// lib/features/orders/data/models/order_model.dart
import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.customerName,
    required super.customerPhone,
    required super.deliveryAddress,
    required super.items,
    required super.totalAmount,
    required super.status,
    required super.tabType,
    required super.eta,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      deliveryAddress: json['delivery_address'] as String,
      items: List<String>.from(json['items'] as List),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: _parseStatus(json['status'] as String),
      tabType: _parseTabType(json['tab_type'] as String),
      eta: json['eta'] as String,
    );
  }

  static OrderStatusType _parseStatus(String status) {
    switch (status) {
      case 'en_route':
        return OrderStatusType.enRoute;
      case 'delivered':
        return OrderStatusType.delivered;
      case 'cancelled':
        return OrderStatusType.cancelled;
      case 'scheduled':
        return OrderStatusType.scheduled;
      case 'pending':
      default:
        return OrderStatusType.pending;
    }
  }

  static OrderTabType _parseTabType(String tab) {
    switch (tab) {
      case 'past':
        return OrderTabType.past;
      case 'scheduled':
        return OrderTabType.scheduled;
      case 'active':
      default:
        return OrderTabType.active;
    }
  }
}
