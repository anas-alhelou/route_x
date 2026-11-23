// lib/features/home/presentation/widgets/setup_steps_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/features/home/domain/entities/setup_progress.dart';

/// The tinted "Get started" panel: a call to action, a readiness line and the
/// three setup gates.
///
/// The step columns are `Expanded` rather than fixed widths. Figma draws them
/// 90.67 / 105.67 / 105.67, which only divide evenly at 412pt; equal weights
/// keep the three gates aligned in any locale, and the Arabic labels are longer
/// than the English ones and need the room anyway.
class SetupStepsCard extends StatelessWidget {
  const SetupStepsCard({
    required this.progress,
    required this.onTap,
    super.key,
  });

  final SetupProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(AppSizes.r18.w),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.r18.w),
          child: Padding(
            // 14 top and bottom, not the 16 the horizontal padding uses: the
            // panel is 158 in the frame and 16/16 makes it 162, which pushes
            // the "Get started" card 4pt past its 220.
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSizes.p16.w,
              AppSpacing.s14.w,
              AppSizes.p16.w,
              AppSpacing.s14.w,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TitleRow(),
                SizedBox(height: AppSpacing.s8.w),
                _MetaRow(
                  done: progress.completedCount,
                  total: progress.steps.length,
                  hasPending: progress.hasPendingStep,
                ),
                const _Divider(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final step in progress.steps)
                      Expanded(
                        child: _Step(
                          status: step.status,
                          label: _label(context, step.id),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Maps a step onto its translated name.
  ///
  /// Lives here rather than on the entity so the domain never holds display
  /// strings, and returns from the enum rather than from an index so adding a
  /// gate cannot silently relabel the others.
  static String _label(BuildContext context, SetupStepId id) {
    final tr = context.tr;
    return switch (id) {
      SetupStepId.account => tr.homeStepAccount,
      SetupStepId.phone => tr.homeStepPhone,
      SetupStepId.fleet => tr.homeStepFleet,
    };
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          AppAssets.icFleetVan,
          width: AppSizes.setupIcon.w,
          height: AppSizes.setupIcon.w,
          // The exported glyph is drawn in the brand's secondary green, which is
          // already correct on the tinted panel — no recolour needed.
        ),
        SizedBox(width: AppSpacing.s10.w),
        Expanded(
          child: Text(
            context.tr.homeJoinFleetToStart,
            style: AppTextStyles.setupTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SvgPicture.asset(
          AppAssets.icChevronRightSm,
          width: AppSizes.iconSm.w,
          height: AppSizes.iconSm.w,
          colorFilter: ColorFilter.mode(
            AppColors.textPrimary,
            BlendMode.srcIn,
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.done,
    required this.total,
    this.hasPending = false,
  });

  final int done;
  final int total;
  final bool hasPending;

  @override
  Widget build(BuildContext context) {
    final metaText = hasPending
        ? context.tr.homeSetupDoneOf(done, total)
        : context.tr.homeReadyStatusDoneOf(done, total);

    return Row(
      children: [
        SvgPicture.asset(
          AppAssets.icList,
          width: AppSizes.iconSm.w,
          height: AppSizes.iconSm.w,
          colorFilter: ColorFilter.mode(
            AppColors.textMuted,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: AppSpacing.s10.w),
        Expanded(
          child: Text(
            metaText,
            style: AppTextStyles.setupMeta.copyWith(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.s12.w),
      child: Container(height: 1, color: AppColors.borderSubtle),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.status, required this.label});

  final SetupStepStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final String statusText;
    final Color statusColor;
    final Color dotColor;

    switch (status) {
      case SetupStepStatus.done:
        statusText = context.tr.homeStepDone;
        statusColor = AppColors.textPrimary;
        dotColor = AppColors.brandMain;
        break;
      case SetupStepStatus.pending:
        statusText = context.tr.homeStepPending;
        statusColor = AppColors.textPrimary;
        dotColor = AppColors.brandMain;
        break;
      case SetupStepStatus.todo:
        statusText = context.tr.homeStepToDo;
        statusColor = AppColors.textMuted;
        dotColor = AppColors.borderDeactivated;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          statusText,
          style: AppTextStyles.stepStatus.copyWith(color: statusColor),
        ),
        SizedBox(height: AppSpacing.s4.w),
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.statLabel.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.s8.w),
            Container(
              width: AppSizes.badgeDot.w,
              height: AppSizes.badgeDot.w,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
