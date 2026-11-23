// lib/features/settings/presentation/controllers/settings_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_profile_entity.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  const SettingsLoaded({required this.profile});
  final DriverProfileEntity profile;

  SettingsLoaded copyWith({DriverProfileEntity? profile}) {
    return SettingsLoaded(profile: profile ?? this.profile);
  }

  @override
  List<Object?> get props => [profile];
}

class SettingsError extends SettingsState {
  const SettingsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class SettingsLoggedOut extends SettingsState {
  const SettingsLoggedOut();
}
