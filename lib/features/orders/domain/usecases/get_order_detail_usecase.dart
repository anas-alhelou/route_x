// lib/features/orders/domain/usecases/get_order_detail_usecase.dart
import '../entities/order_detail_entity.dart';
import '../repositories/order_detail_repository.dart';

class GetOrderDetailUseCase {
  const GetOrderDetailUseCase(this._repository);
  final OrderDetailRepository _repository;

  Future<OrderDetailEntity> call(String orderId) =>
      _repository.getOrderDetail(orderId);
}
