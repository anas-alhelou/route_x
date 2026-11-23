// lib/features/app_permissions/data/repositories/app_permissions_repository_impl.dart
import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../../../core/errors/failures.dart';
import '../../../../core/network/exception_mapper.dart';
import '../../domain/entities/device_setup_entity.dart';
import '../../domain/entities/permission_status_entity.dart';
import '../../domain/repositories/app_permissions_repository.dart';
import '../datasources/app_permissions_local_data_source.dart';
import '../datasources/app_permissions_remote_data_source.dart';
import '../models/device_setup_model.dart';

class AppPermissionsRepositoryImpl implements AppPermissionsRepository {
  const AppPermissionsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    this.exceptionMapper = const ExceptionMapper(),
  });

  final AppPermissionsLocalDataSource localDataSource;
  final AppPermissionsRemoteDataSource remoteDataSource;
  final ExceptionMapper exceptionMapper;

  @override
  Future<Either<Failure, PermissionStatusEntity>> checkPermissionStatus(
    PermissionType type,
  ) => _guard(() async {
        if (type == PermissionType.gallery) {
          final grantedInSignup = await localDataSource.isGalleryGrantedInSignup();
          if (grantedInSignup) {
            developer.log('Gallery pre-granted in signup', name: 'AppPermissions');
            return const PermissionStatusEntity(
              type: PermissionType.gallery,
              status: PermissionStateStatus.granted,
            );
          }
        }

        final phPerm = _mapTypeToPermission(type);
        final status = await phPerm.status;
        developer.log('Checked status for $type: $status', name: 'AppPermissions');

        return PermissionStatusEntity(
          type: type,
          status: _mapStatus(status),
        );
      });

  @override
  Future<Either<Failure, PermissionStatusEntity>> requestPermission(
    PermissionType type,
  ) => _guard(() async {
        if (type == PermissionType.gallery) {
          final grantedInSignup = await localDataSource.isGalleryGrantedInSignup();
          if (grantedInSignup) {
            developer.log('Gallery already granted in signup during request', name: 'AppPermissions');
            return const PermissionStatusEntity(
              type: PermissionType.gallery,
              status: PermissionStateStatus.granted,
            );
          }
        }

        final ph.Permission phPerm = _mapTypeToPermission(type);
        final initialStatus = await phPerm.status;
        developer.log('Requesting permission $type. Initial status: $initialStatus', name: 'AppPermissions');

        final result = await phPerm.request();
        developer.log('Permission $type request result: $result', name: 'AppPermissions');

        if (result.isPermanentlyDenied) {
          developer.log('Permission $type is permanently denied. Opening app settings...', name: 'AppPermissions');
          await ph.openAppSettings();
        }

        if (type == PermissionType.gallery && (result.isGranted || result.isLimited)) {
          await localDataSource.setGalleryGrantedInSignup(true);
        }

        return PermissionStatusEntity(
          type: type,
          status: _mapStatus(result),
        );
      });

  @override
  Future<Either<Failure, bool>> isGalleryGrantedInSignup() => _guard(() async {
        return await localDataSource.isGalleryGrantedInSignup();
      });

  @override
  Future<Either<Failure, void>> submitDeviceSetup(
    DeviceSetupEntity entity,
  ) => _guardVoid(() async {
        final model = DeviceSetupModel.fromEntity(entity);
        developer.log('Submitting device setup: ${model.toJson()}', name: 'AppPermissions');
        try {
          await remoteDataSource
              .submitDeviceSetup(model)
              .timeout(const Duration(seconds: 4));
        } catch (e) {
          developer.log('Device setup submission error (ignored): $e', name: 'AppPermissions');
        }
        await localDataSource.setPermissionsCompleted(true);
      });

  ph.Permission _mapTypeToPermission(PermissionType type) {
    switch (type) {
      case PermissionType.location:
        return ph.Permission.locationWhenInUse;
      case PermissionType.notification:
        return ph.Permission.notification;
      case PermissionType.gallery:
        return ph.Permission.photos;
    }
  }

  PermissionStateStatus _mapStatus(ph.PermissionStatus status) {
    if (status.isGranted || status.isLimited) return PermissionStateStatus.granted;
    if (status.isDenied) return PermissionStateStatus.denied;
    if (status.isPermanentlyDenied) return PermissionStateStatus.permanentlyDenied;
    if (status.isRestricted) return PermissionStateStatus.restricted;
    return PermissionStateStatus.denied;
  }

  Future<Either<Failure, void>> _guardVoid(Future<void> Function() run) async {
    try {
      await run();
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(exceptionMapper.map(error, stackTrace));
    }
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      final value = await run();
      return Right(value);
    } catch (error, stackTrace) {
      return Left(exceptionMapper.map(error, stackTrace));
    }
  }
}
