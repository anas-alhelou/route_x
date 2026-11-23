// lib/features/orders/presentation/widgets/delivery_progress_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_entity.dart';

class DeliveryProgressWidget extends StatelessWidget {
  const DeliveryProgressWidget({super.key, required this.status});

  final OrderStatusType status;

  @override
  Widget build(BuildContext context) {
    int currentStep = 0;
    if (status == OrderStatusType.enRoute) currentStep = 1;
    if (status == OrderStatusType.delivered) currentStep = 2;

    return Row(
      children: [
        _buildStep('Order Placed', true, true),
        _buildLine(currentStep >= 1),
        _buildStep('En Route', currentStep >= 1, currentStep >= 2),
        _buildLine(currentStep >= 2),
        _buildStep('Delivered', currentStep >= 2, false),
      ],
    );
  }

  Widget _buildStep(String title, bool isReached, bool isDone) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isReached ? AppColors.brandMain : AppColors.borderDeactivated,
            ),
            child: Center(
              child: isDone
                  ? Icon(Icons.check, size: 16, color: AppColors.brandBlack)
                  : Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isReached ? AppColors.brandBlack : AppColors.textGray,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isReached ? FontWeight.bold : FontWeight.normal,
              color: isReached ? AppColors.brandBlack : AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 3.h,
        color: isActive ? AppColors.brandMain : AppColors.borderDeactivated,
        margin: EdgeInsets.only(bottom: 20.h),
      ),
    );
  }
}
