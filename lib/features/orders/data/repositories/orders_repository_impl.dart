// lib/features/orders/data/repositories/orders_repository_impl.dart
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_local_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl({required this.localDataSource});

  final OrdersLocalDataSource localDataSource;

  @override
  Future<List<OrderEntity>> getOrders() => localDataSource.getOrders();

  @override
  Future<OrderEntity> updateOrderStatus(String orderId, OrderStatusType newStatus) =>
      localDataSource.updateOrderStatus(orderId, newStatus);
}
