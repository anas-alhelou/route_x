// lib/features/orders/presentation/controllers/order_detail_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/order_detail_entity.dart';

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();
  @override
  List<Object?> get props => [];
}

class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

class OrderDetailLoaded extends OrderDetailState {
  const OrderDetailLoaded(this.detail);
  final OrderDetailEntity detail;
  @override
  List<Object?> get props => [detail];
}

class OrderDetailError extends OrderDetailState {
  const OrderDetailError(this.messageKey);

  /// A key for `context.translateValidationKey`, not finished copy.
  final String messageKey;
  @override
  List<Object?> get props => [messageKey];
}
