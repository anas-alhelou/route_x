// lib/features/home/presentation/widgets/dashboard/referral_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

/// Referral bonus card with a share action.
class ReferralCard extends StatelessWidget {
  const ReferralCard({
    required this.bonus,
    required this.onShare,
    super.key,
  });

  final double bonus;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.brandSecondary),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: AppColors.brandMain,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.card_giftcard_rounded,
              size: 22.r,
              color: AppColors.onBrand,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Referral bonus',
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'SAR ${bonus.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onShare,
            icon: Icon(Icons.ios_share, size: 16.r),
            label: Text(
              'Share',
              style: TextStyle(
                fontFamily: AppFonts.fontFamilySatoshi,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandBlack,
              foregroundColor: AppColors.brandWhite,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            ),
          ),
        ],
      ),
    );
  }
}
