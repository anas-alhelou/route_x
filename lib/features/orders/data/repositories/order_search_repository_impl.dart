// lib/features/orders/data/repositories/order_search_repository_impl.dart
import '../../domain/entities/order_search_result_entity.dart';
import '../../domain/repositories/order_search_repository.dart';
import '../datasources/order_search_local_data_source.dart';

class OrderSearchRepositoryImpl implements OrderSearchRepository {
  const OrderSearchRepositoryImpl({required this.localDataSource});

  final OrderSearchLocalDataSource localDataSource;

  @override
  Future<List<OrderSearchResultEntity>> search(
    String query,
    OrderSearchScope scope,
  ) =>
      localDataSource.search(query, scope);
}
