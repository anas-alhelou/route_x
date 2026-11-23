// lib/features/orders/presentation/widgets/orders_today/delivered_today_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

import 'orders_row_tile.dart';

/// Closes out today's list with what is already done.
///
/// It lives inside the same card as the open stops, at the bottom, because
/// finished work is context for the remaining work — not a separate section
/// the driver has to go find.
class DeliveredTodayTile extends StatelessWidget {
  const DeliveredTodayTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OrdersRowTile(
      onTap: onTap,
      leading: OrdersRowBadge(
        background: AppColors.iconBrand,
        borderColor: AppColors.brandMain,
        child: Assets.icons.svg.delivered.svg(width: 22.w, height: 22.w),
      ),
      title: title,
      subtitle: subtitle,
    );
  }
}
