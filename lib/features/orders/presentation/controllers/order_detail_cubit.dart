// lib/features/orders/presentation/controllers/order_detail_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_order_detail_usecase.dart';
import 'order_detail_state.dart';

class OrderDetailCubit extends Cubit<OrderDetailState> {
  OrderDetailCubit({required GetOrderDetailUseCase getOrderDetailUseCase})
      : _getOrderDetailUseCase = getOrderDetailUseCase,
        super(const OrderDetailLoading());

  final GetOrderDetailUseCase _getOrderDetailUseCase;

  Future<void> load(String orderId) async {
    emit(const OrderDetailLoading());
    try {
      final detail = await _getOrderDetailUseCase(orderId);
      if (isClosed) return;
      emit(OrderDetailLoaded(detail));
    } catch (_) {
      if (isClosed) return;
      emit(const OrderDetailError('errOrderDetailLoadFailed'));
    }
  }
}
