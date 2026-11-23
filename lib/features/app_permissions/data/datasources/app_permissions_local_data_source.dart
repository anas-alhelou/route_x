// lib/features/app_permissions/data/datasources/app_permissions_local_data_source.dart
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppPermissionsLocalDataSource {
  Future<bool> isGalleryGrantedInSignup();
  Future<void> setGalleryGrantedInSignup(bool granted);
  Future<void> setPermissionsCompleted(bool completed);
  Future<bool> isPermissionsCompleted();
}

class AppPermissionsLocalDataSourceImpl implements AppPermissionsLocalDataSource {
  const AppPermissionsLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _galleryGrantedKey = 'gallery_permission_granted_in_signup';
  static const String _permissionsCompletedKey = 'is_permissions_completed';

  @override
  Future<bool> isGalleryGrantedInSignup() async {
    final val = _prefs.getString(_galleryGrantedKey);
    return val == 'true';
  }

  @override
  Future<void> setGalleryGrantedInSignup(bool granted) async {
    await _prefs.setString(_galleryGrantedKey, granted ? 'true' : 'false');
  }

  @override
  Future<void> setPermissionsCompleted(bool completed) async {
    await _prefs.setString(_permissionsCompletedKey, completed ? 'true' : 'false');
  }

  @override
  Future<bool> isPermissionsCompleted() async {
    final val = _prefs.getString(_permissionsCompletedKey);
    return val == 'true';
  }
}
