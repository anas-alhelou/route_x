// lib/features/app_permissions/presentation/controllers/permissions_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/device_setup_entity.dart';
import '../../domain/entities/permission_status_entity.dart';
import '../../domain/repositories/app_permissions_repository.dart';
import '../../domain/usecases/check_permission_status_usecase.dart';
import '../../domain/usecases/request_permission_usecase.dart';
import '../../domain/usecases/submit_device_setup_usecase.dart';
import 'permissions_state.dart';

class PermissionsCubit extends Cubit<PermissionsState> {
  PermissionsCubit({
    required this.checkPermissionStatusUseCase,
    required this.requestPermissionUseCase,
    required this.submitDeviceSetupUseCase,
    required this.repository,
  }) : super(const PermissionsInitial());

  final CheckPermissionStatusUseCase checkPermissionStatusUseCase;
  final RequestPermissionUseCase requestPermissionUseCase;
  final SubmitDeviceSetupUseCase submitDeviceSetupUseCase;
  final AppPermissionsRepository repository;

  int _currentStep = 0;
  final Map<PermissionType, PermissionStateStatus> _statuses = {
    PermissionType.location: PermissionStateStatus.denied,
    PermissionType.notification: PermissionStateStatus.denied,
    PermissionType.gallery: PermissionStateStatus.denied,
  };

  Future<void> checkInitialStatuses() async {
    emit(const PermissionsLoading());

    final galleryResult = await repository.isGalleryGrantedInSignup();
    galleryResult.fold(
      (failure) => _statuses[PermissionType.gallery] = PermissionStateStatus.denied,
      (grantedInSignup) async {
        if (grantedInSignup) {
          _statuses[PermissionType.gallery] = PermissionStateStatus.granted;
        } else {
          final galleryRes = await checkPermissionStatusUseCase(PermissionType.gallery);
          galleryRes.fold(
            (_) => _statuses[PermissionType.gallery] = PermissionStateStatus.denied,
            (res) => _statuses[PermissionType.gallery] = res.status,
          );
        }
      },
    );

    final locRes = await checkPermissionStatusUseCase(PermissionType.location);
    locRes.fold(
      (_) => _statuses[PermissionType.location] = PermissionStateStatus.denied,
      (res) => _statuses[PermissionType.location] = res.status,
    );

    final notifRes = await checkPermissionStatusUseCase(PermissionType.notification);
    notifRes.fold(
      (_) => _statuses[PermissionType.notification] = PermissionStateStatus.denied,
      (res) => _statuses[PermissionType.notification] = res.status,
    );

    emit(PermissionsStepChanged(currentStep: _currentStep, statuses: Map.from(_statuses)));
  }

  void setStep(int step) {
    _currentStep = step;
    emit(PermissionsStepChanged(currentStep: _currentStep, statuses: Map.from(_statuses)));
  }

  Future<void> requestCurrentPermission(int step) async {
    PermissionType type;
    if (step == 0) {
      type = PermissionType.location;
    } else if (step == 1) {
      type = PermissionType.notification;
    } else {
      type = PermissionType.gallery;
    }

    emit(PermissionsStepChanged(currentStep: _currentStep, statuses: Map.from(_statuses), isLoading: true));

    final result = await requestPermissionUseCase(type);
    result.fold(
      (failure) {
        _statuses[type] = PermissionStateStatus.denied;
      },
      (res) {
        _statuses[type] = res.status;
      },
    );

    if (step == 0 && _statuses[type] == PermissionStateStatus.granted) {
      try {
        final accuracy = await Geolocator.getLocationAccuracy();
        if (accuracy == LocationAccuracyStatus.reduced) {
          emit(PermissionsApproximateLocationRequired(currentStep: _currentStep, statuses: Map.from(_statuses)));
          return;
        }
      } catch (_) {}
    }

    if (_currentStep < 2) {
      _currentStep++;
      emit(PermissionsStepChanged(currentStep: _currentStep, statuses: Map.from(_statuses), isLoading: false));
    } else {
      await _submitDeviceSetupAndFinish();
    }
  }

  Future<void> _submitDeviceSetupAndFinish() async {
    final entity = DeviceSetupEntity(
      locationGranted: _statuses[PermissionType.location] == PermissionStateStatus.granted,
      notificationGranted: _statuses[PermissionType.notification] == PermissionStateStatus.granted,
      galleryGranted: _statuses[PermissionType.gallery] == PermissionStateStatus.granted,
    );
    await submitDeviceSetupUseCase(entity);
    emit(const PermissionsCompleted());
  }
}
