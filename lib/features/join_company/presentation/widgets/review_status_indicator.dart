import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

class ReviewStatusIndicator extends StatefulWidget {
  const ReviewStatusIndicator({
    super.key,
    required this.isChecking,
    required this.idleText,
    required this.checkingText,
    required this.onTap,
  });

  final bool isChecking;
  final String idleText;
  final String checkingText;
  final VoidCallback onTap;

  @override
  State<ReviewStatusIndicator> createState() => _ReviewStatusIndicatorState();
}

class _ReviewStatusIndicatorState extends State<ReviewStatusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinnerController;

  @override
  void initState() {
    super.initState();
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isChecking) {
      _spinnerController.repeat();
    }
  }

  @override
  void didUpdateWidget(ReviewStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecking && !_spinnerController.isAnimating) {
      _spinnerController.repeat();
    } else if (!widget.isChecking && _spinnerController.isAnimating) {
      _spinnerController.stop();
      _spinnerController.reset();
    }
  }

  @override
  void dispose() {
    _spinnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RouteXTapScale(
      onTap: widget.isChecking ? null : widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 28.h,
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: widget.isChecking
              ? Row(
                  key: const ValueKey('checking'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RotationTransition(
                      turns: _spinnerController,
                      child: SvgPicture.asset(
                        AppAssets.icSpinner,
                        width: 16.w,
                        height: 16.h,
                        colorFilter: ColorFilter.mode(
                          AppColors.textPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.s8.w),
                    Flexible(
                      child: Text(
                        widget.checkingText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.s14Medium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('idle'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppAssets.icArrowDown,
                      width: 12.w,
                      height: 12.h,
                      colorFilter: ColorFilter.mode(
                        AppColors.textMuted,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 9.w),
                    Flexible(
                      child: Text(
                        widget.idleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.s14Regular.copyWith(
                          color: AppColors.textMuted,
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
