// lib/features/home/presentation/widgets/go_online/go_online_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';
import 'package:routex_mobile/features/home/presentation/navigation/home_navigator.dart';
import 'package:routex_mobile/features/home/presentation/widgets/go_online/go_online_chrome.dart';
import 'package:routex_mobile/features/home/presentation/widgets/go_online/go_online_variant.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';

export 'go_online_variant.dart' show GoOnlineBlockedReason;

/// Displays the modal bottom sheet for when a driver tries to go online without
/// an approved fleet.
///
/// The scrim is [AppColors.scrim] rather than Flutter's default, so the backdrop
/// is the same value on all three sheets; the sheet itself supplies its own white
/// surface and 24pt top corners, which is why the route asks for a transparent
/// background instead of letting `showModalBottomSheet` paint one.
///
/// [navigator] is injectable so a test can assert that the sheet's buttons route
/// somewhere without standing up a real [Navigator].
Future<void> showGoOnlineSheet(
  BuildContext context, {
  required GoOnlineBlockedReason reason,
  HomeOverview? overview,
  HomeNavigator navigator = const HomeNavigator(),
}) {
  return showRoutexSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    builder: (sheetContext) => GoOnlineSheet(
      reason: reason,
      overview: overview,
      navigator: navigator,
    ),
  );
}

/// The reusable modal bottom sheet content for the Go-Online blocked flow.
///
/// One shell for all three frames - handle, tinted disc, heading, body, variant
/// panel, actions - with only the panel and the buttons swapped per reason. The
/// design draws the three as the same sheet at three heights rather than as
/// three unrelated modals, so the shared parts are deliberately shared, and what
/// differs is asked of a [GoOnlineVariant] instead of being switched on here.
///
/// This class contains no `switch` and no knowledge of any individual frame.
/// That is the point of the split: the sheet is the layout, and a frame is data.
class GoOnlineSheet extends StatelessWidget {
  const GoOnlineSheet({
    super.key,
    required this.reason,
    this.overview,
    this.navigator = const HomeNavigator(),
  });

  /// Which blocked frame to draw.
  final GoOnlineBlockedReason reason;

  /// The snapshot the frame names, when the caller has one.
  final HomeOverview? overview;

  /// How the frame's buttons leave the screen.
  final HomeNavigator navigator;

  @override
  Widget build(BuildContext context) {
    final variant = GoOnlineVariant.of(
      reason,
      overview: overview,
      navigator: navigator,
    ) as GoOnlineVariantBase;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.r24.r),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.p24.w,
        vertical: AppSpacing.s12.h,
      ),
      child: SafeArea(
        // The sheet is a bottom sheet: the top inset belongs to whatever is
        // behind it, and adding one here would push the content down.
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GoOnlineSheetHandle(),
            SizedBox(height: AppSpacing.s20.h),
            GoOnlineIconWell(variant: variant),
            SizedBox(height: AppSpacing.s16.h),
            GoOnlineHeaders(variant: variant),
            SizedBox(height: AppSpacing.s20.h),
            variant.buildPanel(context),
            SizedBox(height: AppSpacing.s24.h),
            ...variant.buildActions(context),
            SizedBox(height: AppSpacing.s8.h),
          ],
        ),
      ),
    );
  }
}