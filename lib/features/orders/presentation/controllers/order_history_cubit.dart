// lib/features/orders/presentation/controllers/order_history_cubit.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/network/network_info.dart';

import '../../domain/entities/order_history_entity.dart';
import '../../domain/usecases/get_order_history_usecase.dart';
import 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  OrderHistoryCubit({
    required GetOrderHistoryUseCase getOrderHistoryUseCase,
    required NetworkInfo networkInfo,
  })  : _getOrderHistoryUseCase = getOrderHistoryUseCase,
        super(const OrderHistoryState()) {
    _networkSubscription = networkInfo.onStatusChange.listen(_onNetworkChanged);
  }

  final GetOrderHistoryUseCase _getOrderHistoryUseCase;
  late final StreamSubscription<bool> _networkSubscription;

  /// Bumped on every load. Tapping Week then Month quickly must end on
  /// Month, even if Week's answer arrives second.
  int _generation = 0;

  Future<void> load() => _load(state.period);

  /// Fetch the current period again without the skeleton — after the
  /// queue synced, say, when only the numbers have moved.
  Future<void> refresh() => _load(state.period, quiet: true);

  void selectPeriod(HistoryPeriod period) {
    if (period == state.period && state.status != OrderHistoryStatus.failed) {
      return;
    }
    _load(period);
  }

  /// Back online while showing the saved copy: fetch again in place. No
  /// skeleton — the saved numbers stay up until the live ones replace them.
  void _onNetworkChanged(bool connected) {
    if (connected && state.isOffline) _load(state.period, quiet: true);
  }

  Future<void> _load(HistoryPeriod period, {bool quiet = false}) async {
    final generation = ++_generation;
    emit(
      quiet
          ? state.copyWith(refreshing: true)
          : OrderHistoryState(period: period),
    );
    try {
      final snapshot = await _getOrderHistoryUseCase(period);
      if (isClosed || generation != _generation) return;
      emit(
        OrderHistoryState(
          period: period,
          status: OrderHistoryStatus.loaded,
          data: snapshot.data,
          updatedAt: snapshot.updatedAt,
          isOffline: snapshot.isFromCache,
          pendingSyncCount: snapshot.pendingSyncCount,
        ),
      );
    } catch (_) {
      if (isClosed || generation != _generation) return;
      // A quiet refresh that fails keeps what is on screen.
      if (quiet) {
        emit(state.copyWith(refreshing: false));
        return;
      }
      emit(
        OrderHistoryState(period: period, status: OrderHistoryStatus.failed),
      );
    }
  }

  @override
  Future<void> close() async {
    await _networkSubscription.cancel();
    return super.close();
  }
}
