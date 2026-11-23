// lib/features/notifications/presentation/widgets/notifications_empty_state.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:routex_mobile/core/widgets/routex_pop_in.dart';

/// Notifications Empty State matching Figma N02.
///
/// Centered 170 x 156 3D bell illustration, 28 space, title, 10 space, 2-line desc.
class NotificationsEmptyState extends StatelessWidget {
  const NotificationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Double tap or tap on empty area toggles back to populated for quick testing
        onDoubleTap: () {
          context.read<NotificationsBloc>().add(const NotificationsToggleEmpty());
        },
        child: Container(
          width: 332.w,
          padding: EdgeInsets.symmetric(horizontal: AppSizes.p16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 170 x 156 3D bell illustration with green badge "1" from Figma
              RouteXPopIn(
                child: Image.asset(
                  AppAssets.imgNotificationsEmpty,
                  width: 170.w,
                  height: 156.h,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              SizedBox(height: AppSpacing.s28.h),

              // Title (29h, centered bold text)
              Text(
                context.tr.notificationsEmptyTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontFamilyFallback: AppFonts.fontFamilyFallback,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 29 / 22,
                ),
              ),
              SizedBox(height: AppSpacing.s10.h),

              // Two-line centered description
              Text(
                context.tr.notificationsEmptyDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontFamilyFallback: AppFonts.fontFamilyFallback,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                  height: 21 / 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
