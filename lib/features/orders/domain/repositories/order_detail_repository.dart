// lib/features/orders/domain/repositories/order_detail_repository.dart
import '../entities/order_detail_entity.dart';

abstract class OrderDetailRepository {
  Future<OrderDetailEntity> getOrderDetail(String orderId);
}
