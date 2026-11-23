// lib/features/orders/presentation/controllers/order_search_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/order_search_result_entity.dart';

class OrderSearchState extends Equatable {
  const OrderSearchState({
    this.query = '',
    this.scope = OrderSearchScope.all,
    this.results = const [],
  });

  final String query;
  final OrderSearchScope scope;

  /// Matches for [query] within [scope]. Kept on screen while the next
  /// keystroke's results load, so typing never flashes an empty list.
  final List<OrderSearchResultEntity> results;

  /// Nothing typed yet: the screen shows its help text and no result list.
  bool get isIdle => query.trim().isEmpty;

  OrderSearchState copyWith({
    String? query,
    OrderSearchScope? scope,
    List<OrderSearchResultEntity>? results,
  }) {
    return OrderSearchState(
      query: query ?? this.query,
      scope: scope ?? this.scope,
      results: results ?? this.results,
    );
  }

  @override
  List<Object?> get props => [query, scope, results];
}
