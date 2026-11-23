// lib/features/home/presentation/widgets/go_online/go_online_progress_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// The "no fleet" frame's panel: Account done, Phone done, Fleet next.
///
/// Drawn on the page canvas rather than white so it reads as an inset well inside
/// the sheet instead of a second card competing with the buttons below it.
///
/// The three steps are drawn from fixed positions rather than from a real
/// [SetupProgress], because the design fixes this frame: the first two gates are
/// always done and the third is always next. Deriving them from the driver's
/// actual progress would make the frame say something different from the one
/// that was designed, and the setup card on the dashboard is where their real
/// state is already shown.
class GoOnlineProgressPanel extends StatelessWidget {
  const GoOnlineProgressPanel({super.key});

  /// The design's own step number for the unfinished gate.
  static const String _nextStepNumber = '3';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.p16.w,
        vertical: AppSpacing.s14.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceCanvas,
        borderRadius: BorderRadius.circular(AppSizes.r12.r),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          GoOnlineProgressStep(
            isDone: true,
            name: context.tr.goOnlineSheetProgressAccount,
            badge: context.tr.goOnlineSheetProgressDone,
          ),
          const _StepDivider(),
          GoOnlineProgressStep(
            isDone: true,
            name: context.tr.goOnlineSheetProgressPhone,
            badge: context.tr.goOnlineSheetProgressDone,
          ),
          const _StepDivider(),
          GoOnlineProgressStep(
            isDone: false,
            // The third step is the only unfinished one on this frame, so its
            // marker is a numeral rather than a tick.
            markerLabel: _nextStepNumber,
            name: context.tr.goOnlineSheetProgressFleet,
            badge: context.tr.goOnlineSheetProgressNext,
          ),
        ],
      ),
    );
  }
}

/// The 1pt vertical rule between two steps.
class _StepDivider extends StatelessWidget {
  const _StepDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.s1.w,
      height: AppSpacing.s36.h,
      color: AppColors.borderSubtle,
    );
  }
}

/// One step of the progress panel: a marker, its name, and a status pill.
class GoOnlineProgressStep extends StatelessWidget {
  const GoOnlineProgressStep({
    super.key,
    required this.isDone,
    required this.name,
    required this.badge,
    this.markerLabel,
  });

  /// Whether the step is finished, which decides between a tick and a numeral.
  final bool isDone;

  /// Localized step name.
  final String name;

  /// Localized status word, e.g. "Done" or "Next".
  final String badge;

  /// The digit inside an unfinished marker. Ignored when [isDone].
  final String? markerLabel;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          _StepMarker(isDone: isDone, label: markerLabel),
          SizedBox(height: AppSpacing.s6.h),
          Text(
            name,
            maxLines: 1,
            // A step name has no shorter form to fall back to — "Phone" cannot
            // become "Ph" — so it ellipsizes rather than wrapping, which would
            // push the three columns to different heights.
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.progressStepName.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.s4.h),
          _StepStatusPill(isDone: isDone, label: badge),
        ],
      ),
    );
  }
}

/// The 28pt circle in front of a step: a filled green disc with a white tick, or
/// an outlined ring with the step number.
class _StepMarker extends StatelessWidget {
  const _StepMarker({required this.isDone, this.label});

  final bool isDone;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.stepMarker.w,
      height: AppSizes.stepMarker.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDone ? AppColors.brandMain : Colors.transparent,
        shape: BoxShape.circle,
        border: isDone ? null : Border.all(color: AppColors.borderDeactivated),
      ),
      child: isDone
          ? SvgPicture.asset(
              AppAssets.icCheck,
              width: AppSizes.iconXs.w,
              height: AppSizes.iconXs.w,
              colorFilter: ColorFilter.mode(
                AppColors.surfaceWhite,
                BlendMode.srcIn,
              ),
            )
          : Text(
              label ?? '',
              style: AppTextStyles.stepMarkerNumber.copyWith(
                color: AppColors.textMuted,
              ),
            ),
    );
  }
}

/// The Done/Next pill under a step name.
class _StepStatusPill extends StatelessWidget {
  const _StepStatusPill({required this.isDone, required this.label});

  final bool isDone;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s2.h,
      ),
      decoration: BoxDecoration(
        color: isDone ? AppColors.surfaceStepDone : AppColors.surfaceStepNext,
        borderRadius: BorderRadius.circular(AppSizes.rPill.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.progressStepStatus.copyWith(
          fontWeight: FontWeight.w600,
          color: isDone ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }
}