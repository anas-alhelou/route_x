// lib/features/orders/presentation/widgets/order_card_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import '../../domain/entities/order_entity.dart';

class OrderCardWidget extends StatelessWidget {
  const OrderCardWidget({
    super.key,
    required this.order,
    required this.onTap,
  });

  final OrderEntity order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (order.status) {
      case OrderStatusType.delivered:
        statusColor = AppColors.success;
        break;
      case OrderStatusType.enRoute:
        statusColor = AppColors.brandMain;
        break;
      case OrderStatusType.cancelled:
        statusColor = AppColors.error;
        break;
      case OrderStatusType.scheduled:
      case OrderStatusType.pending:
        statusColor = AppColors.warning;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandBlack.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandBlack,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    order.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              order.customerName,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.brandBlack),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: AppColors.textGray),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    order.deliveryAddress,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.textGray),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            const Divider(),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ETA: ${order.eta}',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.brandBlack),
                ),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
