// lib/features/orders/domain/usecases/get_orders_today_usecase.dart
import '../entities/orders_today_snapshot.dart';
import '../repositories/orders_today_repository.dart';

class GetOrdersTodayUseCase {
  const GetOrdersTodayUseCase(this._repository);
  final OrdersTodayRepository _repository;

  Future<OrdersTodaySnapshot> call() => _repository.getOrdersToday();
}
