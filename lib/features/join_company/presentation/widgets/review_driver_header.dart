import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_avatar.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

class ReviewDriverHeader extends StatelessWidget {
  const ReviewDriverHeader({
    super.key,
    required this.driverName,
    this.avatarName,
    required this.accountTypeLabel,
    required this.logOutLabel,
    required this.onLogOut,
  });

  final String driverName;

  /// The plain driver name the avatar takes its initials from ([driverName] is
  /// the whole greeting, e.g. "Hi, Hamza").
  final String? avatarName;
  final String accountTypeLabel;
  final String logOutLabel;
  final VoidCallback onLogOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Driver avatar with lime-green ring
        RouteXAvatar(
          size: 40.w,
          name: avatarName,
          ringColor: AppColors.brandMain,
          ringWidth: AppSpacing.s2.w,
        ),
        SizedBox(width: AppSpacing.s12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driverName,
                style: AppTextStyles.s16Bold.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.s2.h),
              Text(
                accountTypeLabel,
                style: AppTextStyles.s14Regular.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        RouteXTapScale(
          onTap: onLogOut,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppAssets.icLogout,
                width: 18.w,
                height: 18.h,
                colorFilter: ColorFilter.mode(
                  AppColors.textMuted,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: AppSpacing.s6.w),
              Text(
                logOutLabel,
                style: AppTextStyles.s14Medium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
