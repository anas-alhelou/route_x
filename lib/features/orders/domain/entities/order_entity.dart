// lib/features/orders/domain/entities/order_entity.dart
import 'package:equatable/equatable.dart';

enum OrderTabType { active, past, scheduled }
enum OrderStatusType { pending, enRoute, delivered, cancelled, scheduled }

class OrderEntity extends Equatable {
  const OrderEntity({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.tabType,
    required this.eta,
  });

  final String id;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final List<String> items;
  final double totalAmount;
  final OrderStatusType status;
  final OrderTabType tabType;
  final String eta;

  @override
  List<Object?> get props => [
        id,
        customerName,
        customerPhone,
        deliveryAddress,
        items,
        totalAmount,
        status,
        tabType,
        eta,
      ];
}
