// lib/features/orders/data/repositories/order_detail_repository_impl.dart
import '../../domain/entities/order_detail_entity.dart';
import '../../domain/repositories/order_detail_repository.dart';
import '../datasources/order_detail_local_data_source.dart';

class OrderDetailRepositoryImpl implements OrderDetailRepository {
  const OrderDetailRepositoryImpl({required this.localDataSource});

  final OrderDetailLocalDataSource localDataSource;

  @override
  Future<OrderDetailEntity> getOrderDetail(String orderId) =>
      localDataSource.getOrderDetail(orderId);
}
