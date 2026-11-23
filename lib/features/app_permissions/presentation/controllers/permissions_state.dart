// lib/features/app_permissions/presentation/controllers/permissions_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/permission_status_entity.dart';

abstract class PermissionsState extends Equatable {
  const PermissionsState();

  @override
  List<Object?> get props => [];
}

class PermissionsInitial extends PermissionsState {
  const PermissionsInitial();
}

class PermissionsLoading extends PermissionsState {
  const PermissionsLoading();
}

class PermissionsStepChanged extends PermissionsState {
  const PermissionsStepChanged({
    required this.currentStep,
    required this.statuses,
    this.isLoading = false,
  });

  final int currentStep;
  final Map<PermissionType, PermissionStateStatus> statuses;
  final bool isLoading;

  @override
  List<Object?> get props => [currentStep, statuses, isLoading];
}

class PermissionsCompleted extends PermissionsState {
  const PermissionsCompleted();
}

class PermissionsError extends PermissionsState {
  const PermissionsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class PermissionsApproximateLocationRequired extends PermissionsState {
  const PermissionsApproximateLocationRequired({
    required this.currentStep,
    required this.statuses,
  });

  final int currentStep;
  final Map<PermissionType, PermissionStateStatus> statuses;

  @override
  List<Object?> get props => [currentStep, statuses];
}
