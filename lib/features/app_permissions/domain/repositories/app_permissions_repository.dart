// lib/features/app_permissions/domain/repositories/app_permissions_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/device_setup_entity.dart';
import '../entities/permission_status_entity.dart';

abstract class AppPermissionsRepository {
  Future<Either<Failure, PermissionStatusEntity>> checkPermissionStatus(PermissionType type);
  Future<Either<Failure, PermissionStatusEntity>> requestPermission(PermissionType type);
  Future<Either<Failure, bool>> isGalleryGrantedInSignup();
  Future<Either<Failure, void>> submitDeviceSetup(DeviceSetupEntity entity);
}
