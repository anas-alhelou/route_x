// lib/features/route_fleet/presentation/widgets/route_error_view.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';

/// Shown by the Route tab when loading the route failed.
///
/// Without it the tab rendered nothing at all for a failed load: a blank white
/// screen with only the bottom bar, and no way to try again. In debug builds
/// the raw [message] is printed under the title so the cause is visible while
/// developing; release builds show only the friendly text.
class RouteErrorView extends StatelessWidget {
  const RouteErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 26.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 40.sp,
                color: AppColors.textGray,
              ),
              SizedBox(height: 12.h),
              Text(
                context.tr.somethingWentWrong,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (kDebugMode) ...[
                SizedBox(height: 8.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textGray),
                ),
              ],
              SizedBox(height: 20.h),
              RouteXMainButton(text: context.tr.routeRetry, onPressed: onRetry),
            ],
          ),
        ),
      ),
    );
  }
}
