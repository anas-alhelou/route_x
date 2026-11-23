// lib/features/orders/presentation/controllers/orders_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();
  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  const OrdersLoaded({
    required this.orders,
    required this.selectedTab,
  });

  final List<OrderEntity> orders;
  final OrderTabType selectedTab;

  OrdersLoaded copyWith({
    List<OrderEntity>? orders,
    OrderTabType? selectedTab,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }

  @override
  List<Object?> get props => [orders, selectedTab];
}

class OrdersError extends OrdersState {
  const OrdersError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
