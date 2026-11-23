import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/direction_mirror_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/widgets/routex_cta_label.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

class RouteXSecondaryCta extends StatelessWidget {
  const RouteXSecondaryCta({
    required this.label,
    super.key,
    this.onPressed,
    this.leadingWidget,
    this.showTrailingArrow = false,
    this.height = AppSizes.buttonH52,
    this.backgroundColor,
    this.labelColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leadingWidget;
  final bool showTrailingArrow;
  final double height;
  final Color? backgroundColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderRadius = BorderRadius.circular(AppSizes.r6.r);
    final bg = backgroundColor ?? colors.surface;
    final fg = labelColor ?? colors.textPrimary;

    return RouteXPressable(
      onTap: onPressed,
      isEnabled: onPressed != null,
      child: SizedBox(
        width: double.infinity,
        height: height.h,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            side: BorderSide(color: colors.border),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
          ),
          onPressed: onPressed,
          child: leadingWidget != null
              ? _CentredLayout(label: label, leading: leadingWidget!)
              : _SpreadLayout(
                  label: label,
                  labelColor: fg,
                  showTrailingArrow: showTrailingArrow,
                ),
        ),
      ),
    );
  }
}

class _CentredLayout extends StatelessWidget {
  const _CentredLayout({required this.label, required this.leading});

  final String label;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        leading,
        SizedBox(width: AppSpacing.s8.w),
        Flexible(
          child: RouteXCtaLabel(label: label, color: colors.textPrimary),
        ),
      ],
    );
  }
}

class _SpreadLayout extends StatelessWidget {
  const _SpreadLayout({
    required this.label,
    required this.labelColor,
    required this.showTrailingArrow,
  });

  final String label;
  final Color labelColor;
  final bool showTrailingArrow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.s20,
        0,
        AppSpacing.s16,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: RouteXCtaLabel(label: label, color: labelColor),
            ),
          ),
          if (showTrailingArrow)
            SvgPicture.asset(
              AppAssets.icArrow,
              width: AppSizes.iconSm.w,
              height: AppSizes.iconSm.w,
              colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
            ).mirroredInRtl(context),
        ],
      ),
    );
  }
}
