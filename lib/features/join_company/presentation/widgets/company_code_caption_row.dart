import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

class CompanyCodeCaptionRow extends StatelessWidget {
  const CompanyCodeCaptionRow({
    super.key,
    required this.caption,
    required this.pasteLabel,
    required this.onPaste,
  });

  final String caption;
  final String pasteLabel;
  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            caption,
            style: AppTextStyles.s12Regular.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
        RouteXTapScale(
          onTap: onPaste,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppAssets.icClipboard,
                width: 12.w,
                height: 12.h,
                colorFilter: ColorFilter.mode(
                  AppColors.brandBlack,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                pasteLabel,
                style: AppTextStyles.s12Bold.copyWith(
                  color: AppColors.brandBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
