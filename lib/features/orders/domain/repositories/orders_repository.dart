// lib/features/orders/domain/repositories/orders_repository.dart
import '../entities/order_entity.dart';

abstract class OrdersRepository {
  Future<List<OrderEntity>> getOrders();
  Future<OrderEntity> updateOrderStatus(String orderId, OrderStatusType newStatus);
}
