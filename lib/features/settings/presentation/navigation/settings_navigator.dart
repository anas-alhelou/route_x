// lib/features/settings/presentation/navigation/settings_navigator.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/nearby_fleet_entity.dart';
import '../controllers/settings_cubit.dart';

/// `extra` of the settings routes that edit the profile: the settings
/// screen's own [SettingsCubit], so a save there refreshes it, and the
/// profile being edited.
class SettingsProfileArgs {
  const SettingsProfileArgs({required this.cubit, required this.profile});

  final SettingsCubit cubit;
  final DriverProfileEntity profile;
}

/// `extra` of the pending join request route.
class FleetRequestArgs {
  const FleetRequestArgs({required this.fleet, required this.sentAt});

  final NearbyFleetEntity fleet;
  final DateTime sentAt;
}

/// `extra` of the report sent route.
class ReportSentArgs {
  const ReportSentArgs({
    required this.firstName,
    required this.email,
    required this.reference,
  });

  final String firstName;
  final String email;
  final String reference;
}

/// Navigation helpers shared by the settings pages.
abstract final class SettingsNavigator {
  /// Pushes a profile-editing [route] with the [SettingsCubit] in scope.
  static void pushWithProfile(
    BuildContext context,
    String route,
    DriverProfileEntity profile,
  ) {
    context.push(
      route,
      extra: SettingsProfileArgs(cubit: context.read<SettingsCubit>(), profile: profile),
    );
  }
}
