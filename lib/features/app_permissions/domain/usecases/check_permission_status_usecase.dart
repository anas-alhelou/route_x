// lib/features/app_permissions/domain/usecases/check_permission_status_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/permission_status_entity.dart';
import '../repositories/app_permissions_repository.dart';

class CheckPermissionStatusUseCase {
  const CheckPermissionStatusUseCase(this.repository);

  final AppPermissionsRepository repository;

  Future<Either<Failure, PermissionStatusEntity>> call(PermissionType type) async {
    return await repository.checkPermissionStatus(type);
  }
}
