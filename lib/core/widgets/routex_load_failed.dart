import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_primary_cta.dart';

class RouteXLoadFailed extends StatelessWidget {
  const RouteXLoadFailed({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.tr.somethingWentWrong,
            textAlign: TextAlign.center,
            style: AppTextStyles.setupTitle.copyWith(
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.s16.h),
          RouteXPrimaryCta(label: context.tr.retry, onPressed: onRetry),
        ],
      ),
    );
  }
}
