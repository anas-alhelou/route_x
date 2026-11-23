// lib/features/orders/domain/usecases/search_orders_usecase.dart
import '../entities/order_search_result_entity.dart';
import '../repositories/order_search_repository.dart';

class SearchOrdersUseCase {
  const SearchOrdersUseCase(this._repository);
  final OrderSearchRepository _repository;

  /// A blank [query] returns nothing without asking the repository: the
  /// screen shows its help text instead of the driver's whole schedule.
  Future<List<OrderSearchResultEntity>> call(
    String query,
    OrderSearchScope scope,
  ) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    return _repository.search(trimmed, scope);
  }
}
