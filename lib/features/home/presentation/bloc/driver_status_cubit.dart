// lib/features/home/presentation/bloc/driver_status_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_status_entity.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_current_status_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/update_driver_status_usecase.dart';
import 'package:routex_mobile/features/home/presentation/bloc/driver_status_state.dart';

export 'driver_status_state.dart';

/// Owns the driver's online/offline status, independently of the dashboard.
///
/// Keeping it separate from [HomeDashboardBloc] means a status flip does not
/// re-run the dashboard load, and the status card can live and rebuild without
/// the rest of the screen. Updates are optimistic — the switch moves at once and
/// is reverted if the write fails — so the control never feels laggy.
class DriverStatusCubit extends Cubit<DriverStatusState> {
  DriverStatusCubit({
    required GetCurrentStatusUseCase getCurrentStatus,
    required UpdateDriverStatusUseCase updateDriverStatus,
  })  : _getCurrentStatus = getCurrentStatus,
        _updateDriverStatus = updateDriverStatus,
        super(const DriverStatusState());

  final GetCurrentStatusUseCase _getCurrentStatus;
  final UpdateDriverStatusUseCase _updateDriverStatus;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _getCurrentStatus();
    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, errorMessage: failure.message),
      ),
      (status) => emit(state.copyWith(isLoading: false, status: status)),
    );
  }

  Future<void> update(DriverStatus status) async {
    final previous = state.status;

    emit(
      state.copyWith(
        status: DriverStatusEntity(
          status: status,
          lastUpdated: DateTime.now(),
          onlineForDuration: previous?.onlineForDuration,
        ),
        isUpdating: true,
        clearError: true,
      ),
    );

    final result = await _updateDriverStatus(status: status);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: previous,
          isUpdating: false,
          errorMessage: failure.message,
        ),
      ),
      (updated) => emit(state.copyWith(status: updated, isUpdating: false)),
    );
  }
}
