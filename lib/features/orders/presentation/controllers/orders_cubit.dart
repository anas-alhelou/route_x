// lib/features/orders/presentation/controllers/orders_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({
    required GetOrdersUseCase getOrdersUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
  })  : _getOrdersUseCase = getOrdersUseCase,
        _updateOrderStatusUseCase = updateOrderStatusUseCase,
        super(const OrdersInitial());

  final GetOrdersUseCase _getOrdersUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;

  List<OrderEntity> _allOrders = [];

  Future<void> loadOrders() async {
    emit(const OrdersLoading());
    try {
      _allOrders = await _getOrdersUseCase();
      emit(OrdersLoaded(orders: _allOrders, selectedTab: OrderTabType.active));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  void changeTab(OrderTabType tab) {
    final currentState = state;
    if (currentState is OrdersLoaded) {
      emit(currentState.copyWith(selectedTab: tab));
    }
  }

  Future<void> updateStatus(String orderId, OrderStatusType newStatus) async {
    final currentState = state;
    if (currentState is OrdersLoaded) {
      try {
        final updated = await _updateOrderStatusUseCase(orderId, newStatus);
        _allOrders = _allOrders.map((o) => o.id == orderId ? updated : o).toList();
        emit(currentState.copyWith(orders: _allOrders));
      } catch (e) {
        emit(OrdersError(e.toString()));
      }
    }
  }
}
