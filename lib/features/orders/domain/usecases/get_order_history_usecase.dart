// lib/features/orders/domain/usecases/get_order_history_usecase.dart
import '../entities/order_history_entity.dart';
import '../entities/order_history_snapshot.dart';
import '../repositories/order_history_repository.dart';

class GetOrderHistoryUseCase {
  const GetOrderHistoryUseCase(this._repository);
  final OrderHistoryRepository _repository;

  Future<OrderHistorySnapshot> call(HistoryPeriod period) =>
      _repository.getHistory(period);
}
