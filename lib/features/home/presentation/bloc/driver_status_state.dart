// lib/features/home/presentation/bloc/driver_status_state.dart
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_status_entity.dart';

/// State for driver availability.
class DriverStatusState extends Equatable {
  const DriverStatusState({
    this.status,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
  });

  final DriverStatusEntity? status;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;

  bool get isOnline => status?.isOnline ?? false;

  DriverStatusState copyWith({
    DriverStatusEntity? status,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DriverStatusState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, isLoading, isUpdating, errorMessage];
}
