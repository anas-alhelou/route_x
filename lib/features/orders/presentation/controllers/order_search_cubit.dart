// lib/features/orders/presentation/controllers/order_search_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order_search_result_entity.dart';
import '../../domain/usecases/search_orders_usecase.dart';
import 'order_search_state.dart';

class OrderSearchCubit extends Cubit<OrderSearchState> {
  OrderSearchCubit({
    required SearchOrdersUseCase searchOrdersUseCase,
    String initialQuery = '',
  })  : _searchOrdersUseCase = searchOrdersUseCase,
        super(OrderSearchState(query: initialQuery)) {
    if (!state.isIdle) _search();
  }

  final SearchOrdersUseCase _searchOrdersUseCase;

  /// Bumped on every search. A response is applied only if it belongs to the
  /// latest one, so a slow answer for "Ah" can never overwrite the answer
  /// for "Ahmed" that arrived first.
  int _generation = 0;

  void queryChanged(String query) {
    if (query == state.query) return;
    emit(state.copyWith(query: query));
    _search();
  }

  void scopeChanged(OrderSearchScope scope) {
    if (scope == state.scope) return;
    emit(state.copyWith(scope: scope));
    _search();
  }

  Future<void> _search() async {
    final generation = ++_generation;
    final query = state.query;
    final scope = state.scope;

    try {
      final results = await _searchOrdersUseCase(query, scope);
      if (isClosed || generation != _generation) return;
      emit(state.copyWith(results: results));
    } catch (_) {
      // A failed lookup shows as "no matches" rather than an error screen:
      // the driver's next keystroke retries anyway.
      if (isClosed || generation != _generation) return;
      emit(state.copyWith(results: const []));
    }
  }
}
