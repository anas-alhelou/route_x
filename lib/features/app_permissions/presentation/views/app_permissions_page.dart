// lib/features/app_permissions/presentation/views/app_permissions_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/widgets/routex_loading_overlay.dart';
import '../../domain/entities/permission_status_entity.dart';
import '../controllers/permissions_cubit.dart';
import '../controllers/permissions_state.dart';
import '../widgets/permission_step_widget.dart';
import '../widgets/precise_location_required_dialog.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';

class AppPermissionsPage extends StatelessWidget {
  const AppPermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PermissionsCubit(
        checkPermissionStatusUseCase: getIt(),
        requestPermissionUseCase: getIt(),
        submitDeviceSetupUseCase: getIt(),
        repository: getIt(),
      )..checkInitialStatuses(),
      child: const AppPermissionsView(),
    );
  }
}

class AppPermissionsView extends StatelessWidget {
  const AppPermissionsView({super.key});

  void _showApproximateLocationDialog(BuildContext context) {
    showRoutexDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PreciseLocationRequiredDialog(
        onPreciseEnabled: () async {
          try {
            // 1. Try requesting temporary full accuracy from OS
            final status = await Geolocator.requestTemporaryFullAccuracy(
              purposeKey: 'DeliveryRouteTracking',
            );

            if (status == LocationAccuracyStatus.precise) {
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(true);
              }
              if (context.mounted) {
                context.read<PermissionsCubit>().setStep(1);
              }
            } else {
              // 2. Fallback: If status remains reduced or rejected, open App Settings directly
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(false);
              }
              await Geolocator.openAppSettings();
            }
          } catch (e) {
            // 3. Fallback: Direct call to Open Settings on exception or silent failure
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop(false);
            }
            await Geolocator.openAppSettings();
          }
        },
        onOpenSettings: () async {
          Navigator.of(dialogContext).pop(false);
          await Geolocator.openAppSettings();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PermissionsCubit, PermissionsState>(
      listener: (context, state) {
        if (state is PermissionsCompleted) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            context.go(RoutersName.login);
          }
        } else if (state is PermissionsApproximateLocationRequired) {
          _showApproximateLocationDialog(context);
        }
      },
      builder: (context, state) {
        final isLoading = state is PermissionsLoading ||
            (state is PermissionsStepChanged && state.isLoading);

        return RouteXLoadingOverlay(
          isLoading: isLoading,
          child: Scaffold(
            backgroundColor: AppColors.brandBackground,
            body: SafeArea(
              child: Builder(
                builder: (context) {
                  if (state is PermissionsLoading || state is PermissionsInitial) {
                    return const SizedBox.shrink();
                  }

                  if (state is PermissionsStepChanged || state is PermissionsApproximateLocationRequired) {
                    final currentStep = state is PermissionsStepChanged
                        ? state.currentStep
                        : (state as PermissionsApproximateLocationRequired).currentStep;
                    final statuses = state is PermissionsStepChanged
                        ? state.statuses
                        : (state as PermissionsApproximateLocationRequired).statuses;

                    PermissionType type;
                    if (currentStep == 0) {
                      type = PermissionType.location;
                    } else if (currentStep == 1) {
                      type = PermissionType.notification;
                    } else {
                      type = PermissionType.gallery;
                    }

                    final status = statuses[type] ??
                        PermissionStateStatus.denied;

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.05),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: PermissionStepWidget(
                        key: ValueKey<int>(currentStep),
                        stepIndex: currentStep,
                        status: status,
                        onAllowPressed: () {
                          context
                              .read<PermissionsCubit>()
                              .requestCurrentPermission(currentStep);
                        },
                      ),
                    );
                  }

                  if (state is PermissionsError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
