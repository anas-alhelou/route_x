// lib/features/orders/domain/repositories/order_search_repository.dart
import '../entities/order_search_result_entity.dart';

abstract class OrderSearchRepository {
  Future<List<OrderSearchResultEntity>> search(
    String query,
    OrderSearchScope scope,
  );
}
