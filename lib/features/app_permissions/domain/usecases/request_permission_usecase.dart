// lib/features/app_permissions/domain/usecases/request_permission_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/permission_status_entity.dart';
import '../repositories/app_permissions_repository.dart';

class RequestPermissionUseCase {
  const RequestPermissionUseCase(this.repository);

  final AppPermissionsRepository repository;

  Future<Either<Failure, PermissionStatusEntity>> call(PermissionType type) async {
    return await repository.requestPermission(type);
  }
}
