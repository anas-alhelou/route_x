import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_colors_sync.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'delivery_illustration_view.dart';

class CheckPhotoView extends StatelessWidget {
  const CheckPhotoView({
    super.key,
    this.photoPath,
    this.doorNumber,
    required this.requiresSignature,
    required this.onRetakeTapped,
    required this.onPrimaryActionTapped,
  });

  final String? photoPath;
  final String? doorNumber;
  final bool requiresSignature;
  final VoidCallback onRetakeTapped;
  final VoidCallback onPrimaryActionTapped;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(pageSystemUiOverlayStyle());

    final primaryLabel = requiresSignature ? context.tr.routeNextSignature : context.tr.routeUsePhoto;

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 26.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              SizedBox(height: 12.h),

              // 1. Back / Retake button (20, 64)
              InkWell(
                onTap: onRetakeTapped,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppAssets.routeIcBackChevron,
                      width: 24.w,
                      height: 24.h,
                      colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      context.tr.routeRetake,
                      style: AppTextStyles.s15Bold.copyWith(color: AppColors.brandBlack),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // 2. Title & Subtitle (26, 104)
              Text(
                context.tr.routeLooksGood,
                style: AppTextStyles.s28Bold115.copyWith(color: AppColors.brandBlack),
              ),
              SizedBox(height: 4.h),
              Text(
                context.tr.routePhotoClearHint,
                style: AppTextStyles.s14Regular.copyWith(color: AppColors.textBody),
              ),
              SizedBox(height: 16.h),

              // 3. Photo preview box (360 x 440 at y=192, radius 20)
              SizedBox(
                width: 360.w,
                height: 440.h,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
                  ),
                  clipBehavior: Clip.antiAlias,
                  // The photo that was just taken; the Figma illustration when there is none.
                  child: photoPath != null
                      ? Image.file(
                          File(photoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => DeliveryIllustrationView(
                            doorNumber: doorNumber,
                            isFullFrame: false,
                          ),
                        )
                      : DeliveryIllustrationView(
                          doorNumber: doorNumber,
                          isFullFrame: false,
                        ),
                ),
              ),
              SizedBox(height: 24.h),

              // 4. Primary Button ("Use photo" or "Next: signature" at y=652, height 56)
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandMain,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                    ),
                  ),
                  onPressed: onPrimaryActionTapped,
                  child: Text(
                    primaryLabel,
                    style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // 5. Secondary "Retake" button (y=720, height 56)
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surfaceWhite,
                    side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                    ),
                  ),
                  onPressed: onRetakeTapped,
                  child: Text(
                    context.tr.routeRetake,
                    style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
