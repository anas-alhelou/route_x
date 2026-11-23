// lib/features/app_permissions/data/datasources/app_permissions_remote_data_source.dart
import 'package:dio/dio.dart';
import '../models/device_setup_model.dart';

abstract class AppPermissionsRemoteDataSource {
  Future<void> submitDeviceSetup(DeviceSetupModel model);
}

class AppPermissionsRemoteDataSourceImpl implements AppPermissionsRemoteDataSource {
  /// The client is accepted so the DI wiring stays the same; it is unused
  /// until the backend adds an endpoint.
  const AppPermissionsRemoteDataSourceImpl([Dio? _]);

  @override
  Future<void> submitDeviceSetup(DeviceSetupModel model) async {
    // The backend has no device-setup endpoint (the old `/api/v1/driver/
    // device-setup` returned 404 on every call). The push token travels with
    // POST /auth/login instead, so there is nothing to send here.
    // TODO(backend): if an endpoint for permission state is added, call it here.
  }
}
