// lib/features/app_permissions/domain/usecases/submit_device_setup_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/device_setup_entity.dart';
import '../repositories/app_permissions_repository.dart';

class SubmitDeviceSetupUseCase {
  const SubmitDeviceSetupUseCase(this.repository);

  final AppPermissionsRepository repository;

  Future<Either<Failure, void>> call(DeviceSetupEntity entity) async {
    return await repository.submitDeviceSetup(entity);
  }
}
