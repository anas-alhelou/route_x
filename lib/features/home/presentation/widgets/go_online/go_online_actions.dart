// lib/features/home/presentation/widgets/go_online/go_online_actions.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_primary_cta.dart';
import 'package:routex_mobile/core/widgets/routex_secondary_cta.dart';
import 'package:routex_mobile/features/home/presentation/navigation/home_navigator.dart';

/// The action stacks for the three Go Online frames.
///
/// Static methods returning a `List<Widget>` rather than a widget with a
/// `switch` inside: the variant asks for its buttons, the sheet renders whatever
/// list it is given, and neither has to know the other two frames exist. That is
/// the same reason the variants exist for the panels - it removes the second
/// four-way branch out of the sheet.
///
/// [HomeNavigator] is passed in rather than constructed here so a test can drive
/// these buttons without a real router, which is how the existing sheet tests
/// assert the navigations.
abstract final class GoOnlineActions {
  /// The "no fleet" frame: search, enter a code, or dismiss.
  ///
  /// Two paths to the same destination, because the design offers both and a
  /// driver who already has a code should not have to go and find it first.
  static List<Widget> noFleet(
    BuildContext context,
    HomeNavigator navigator,
  ) {
    final tr = context.tr;
    return [
      RouteXPrimaryCta(
        label: tr.goOnlineSheetFindFleet,
        showArrow: true,
        onPressed: () =>
            dismissThen(context, () => navigator.toFindFleet(context)),
      ),
      SizedBox(height: AppSpacing.s10.h),
      RouteXSecondaryCta(
        label: tr.goOnlineSheetEnterCode,
        showTrailingArrow: true,
        onPressed: () =>
            dismissThen(context, () => navigator.toEnterFleetCode(context)),
      ),
      SizedBox(height: AppSpacing.s8.h),
      GoOnlineDismissButton(label: tr.goOnlineSheetNotNow),
    ];
  }

  /// The "pending" frame: view the request, or acknowledge it.
  static List<Widget> pending(
    BuildContext context,
    HomeNavigator navigator,
  ) {
    final tr = context.tr;
    return [
      RouteXPrimaryCta(
        label: tr.goOnlineSheetViewRequest,
        onPressed: () {
          // TODO: View request flow - no screen designed yet.
          Navigator.of(context).pop();
        },
      ),
      SizedBox(height: AppSpacing.s8.h),
      GoOnlineDismissButton(label: tr.goOnlineSheetGotIt),
    ];
  }

  /// The "declined" frame: find another fleet, update the vehicle, or dismiss.
  static List<Widget> declined(
    BuildContext context,
    HomeNavigator navigator,
  ) {
    final tr = context.tr;
    return [
      RouteXPrimaryCta(
        label: tr.goOnlineSheetFindAnotherFleet,
        showArrow: true,
        onPressed: () =>
            dismissThen(context, () => navigator.toFindFleet(context)),
      ),
      SizedBox(height: AppSpacing.s10.h),
      RouteXSecondaryCta(
        label: tr.goOnlineSheetUpdateVehicle,
        leadingWidget: SvgPicture.asset(
          AppAssets.icCar,
          width: AppSizes.iconSm.w,
          height: AppSizes.iconSm.w,
          colorFilter: ColorFilter.mode(
            AppColors.textPrimary,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () {
          // TODO: Update vehicle flow - no screen designed in this task.
          Navigator.of(context).pop();
        },
      ),
      SizedBox(height: AppSpacing.s8.h),
      GoOnlineDismissButton(label: tr.goOnlineSheetNotNow),
    ];
  }

  /// Closes the sheet and then navigates.
  ///
  /// Order matters: navigating first would leave the sheet on screen above the
  /// page it pushed, and the driver would land on Find a fleet with the previous
  /// modal still up.
  static void dismissThen(BuildContext context, VoidCallback navigate) {
    Navigator.of(context).pop();
    navigate();
  }
}

/// The low-emphasis escape hatch at the bottom of a sheet.
class GoOnlineDismissButton extends StatelessWidget {
  const GoOnlineDismissButton({super.key, required this.label});

  /// Localized button text.
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      style: TextButton.styleFrom(
        // Shrink-wrapped: this is a third-tier escape hatch on a sheet that
        // already has two full-width buttons above it, and the design gives it
        // no fill or border of its own.
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s16.w,
          vertical: AppSpacing.s8.h,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.secondaryCtaLabel.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}