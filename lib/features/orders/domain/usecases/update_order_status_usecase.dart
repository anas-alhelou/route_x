// lib/features/orders/domain/usecases/update_order_status_usecase.dart
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class UpdateOrderStatusUseCase {
  const UpdateOrderStatusUseCase(this._repository);
  final OrdersRepository _repository;

  Future<OrderEntity> call(String orderId, OrderStatusType newStatus) =>
      _repository.updateOrderStatus(orderId, newStatus);
}
