// lib/features/settings/presentation/controllers/settings_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/profile_update_exception.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'package:routex_mobile/core/notifications/notification_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _logoutUseCase = logoutUseCase,
        super(const SettingsInitial());

  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final LogoutUseCase _logoutUseCase;

  void _applyPreferences(DriverProfileEntity p) {
    NotificationPreferences.update(
      enabled: p.isNotificationsEnabled,
      newRoutes: p.notifyNewRoutes,
      orderChanges: p.notifyOrderChanges,
      dispatch: p.notifyDispatchMessages,
      sound: p.notificationSound,
      vibrate: p.notificationVibrate,
      quietEnabled: p.quietHoursEnabled,
      quietStartMinutes: p.quietHoursStartMinutes,
      quietEndMinutes: p.quietHoursEndMinutes,
      quietDays: p.quietHoursDays,
    );
  }

  Future<void> loadProfile() async {
    emit(const SettingsLoading());
    try {
      final profile = await _getProfileUseCase();
      _applyPreferences(profile);
      emit(SettingsLoaded(profile: profile));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  /// Saves [profile] and returns `null` on success.
  ///
  /// A refused update is returned rather than emitted: the current profile
  /// stays on screen, and the edit page decides how to show the problem.
  /// Failures that are not a [ProfileUpdateException] are wrapped in one with
  /// just a [ProfileUpdateException.message].
  Future<ProfileUpdateException?> updateProfile(DriverProfileEntity profile) async {
    if (state is! SettingsLoaded) return null;
    try {
      final updated = await _updateProfileUseCase(profile);
      _applyPreferences(updated);
      emit(SettingsLoaded(profile: updated));
      return null;
    } on ProfileUpdateException catch (e) {
      return e;
    } catch (e) {
      return ProfileUpdateException(message: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _logoutUseCase();
      emit(const SettingsLoggedOut());
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
