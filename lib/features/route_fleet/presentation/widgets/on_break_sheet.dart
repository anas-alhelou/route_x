// lib/features/route_fleet/presentation/widgets/on_break_sheet.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class OnBreakSheet extends StatefulWidget {
  const OnBreakSheet({
    super.key,
    required this.breakStartTime,
    required this.allowedMinutes,
    required this.onResumeTapped,
    required this.onAddMinutesTapped,
  });

  final DateTime breakStartTime;
  final int allowedMinutes;
  final VoidCallback onResumeTapped;
  final VoidCallback onAddMinutesTapped;

  @override
  State<OnBreakSheet> createState() => _OnBreakSheetState();
}

class _OnBreakSheetState extends State<OnBreakSheet> {
  Timer? _ticker;
  late int _allowedMins;

  @override
  void initState() {
    super.initState();
    _allowedMins = widget.allowedMinutes;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant OnBreakSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allowedMinutes != widget.allowedMinutes) {
      _allowedMins = widget.allowedMinutes;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final elapsedSeconds = now.difference(widget.breakStartTime).inSeconds;
    final totalAllowedSeconds = _allowedMins * 60;
    final remainingSeconds = (totalAllowedSeconds - elapsedSeconds).clamp(0, totalAllowedSeconds);
    final remainingMins = remainingSeconds ~/ 60;
    final remainingSecs = remainingSeconds % 60;
    final timeStr = '$remainingMins:${remainingSecs.toString().padLeft(2, '0')}';

    final startTimeStr = '${widget.breakStartTime.hour.toString().padLeft(2, '0')}:${widget.breakStartTime.minute.toString().padLeft(2, '0')}';

    return Container(
      width: 360.w,
      decoration: BoxDecoration(
        color: AppColors.brandBackground,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
        boxShadow: AppTextStyles.tripSheetShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Overline
              Text(
                context.tr.routeOnBreakCaps,
                style: AppTextStyles.s10Bold.copyWith(
                  color: AppColors.statusAmber,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8.h),

              // 2. Timer row
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8.w,
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontSize: 48.sp, // Figma R44: 48 Bold
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.92,
                      color: AppColors.brandBlack,
                    ),
                  ),
                  Text(
                    context.tr.routeOfMin(_allowedMins.toString()),
                    style: AppTextStyles.s15Bold.copyWith(color: AppColors.textBody),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // 3. Body info (Figma: 13 Regular)
              Text(
                context.tr.routeBreakStarted(startTimeStr, _allowedMins.toString()),
                style: AppTextStyles.s13Regular145.copyWith(color: AppColors.textBody),
              ),
              // Figma: 8 + a 10px spacer + 8 before the buttons
              SizedBox(height: 26.h),

              // 4. Buttons (column)
              SizedBox(
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandMain,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                    ),
                  ),
                  onPressed: widget.onResumeTapped,
                  child: Text(
                    context.tr.routeResumeRoute,
                    style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                height: 52.h,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.brandBackground,
                    side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _allowedMins += 5;
                    });
                    widget.onAddMinutesTapped();
                  },
                  child: Text(
                    context.tr.routeAdd5Minutes,
                    style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
