// lib/features/orders/domain/usecases/get_orders_usecase.dart
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrdersUseCase {
  const GetOrdersUseCase(this._repository);
  final OrdersRepository _repository;

  Future<List<OrderEntity>> call() => _repository.getOrders();
}
