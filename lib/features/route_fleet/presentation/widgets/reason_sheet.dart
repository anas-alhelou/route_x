import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class ReasonSheet extends StatefulWidget {
  const ReasonSheet({
    super.key,
    required this.customerName,
    required this.companyName,
    required this.onCustomerNotAnsweringTapped,
    required this.onSendToCompanyTapped,
  });

  final String customerName;
  final String companyName;
  final VoidCallback onCustomerNotAnsweringTapped;
  final void Function(String code, String label) onSendToCompanyTapped;

  @override
  State<ReasonSheet> createState() => _ReasonSheetState();
}

class _ReasonSheetState extends State<ReasonSheet> {
  String? _selectedCode;
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, dynamic>> _reasons = const [
    {
      'code': 'notAnswering',
      'label': 'Customer not answering',
      'asset': AppAssets.routeIcCall,
    },
    {
      'code': 'wrongAddress',
      'label': 'Wrong address',
      'asset': AppAssets.routeIcLocation,
    },
    {
      'code': 'refused',
      'label': 'Customer refused',
      'asset': AppAssets.routeIcCancelled,
    },
    {
      'code': 'cantReach',
      'label': "Can't reach location",
      'asset': AppAssets.routeIcNavigate,
    },
  ];

  String _labelFor(BuildContext context, String code) {
    switch (code) {
      case 'notAnswering':
        return context.tr.routeReasonNotAnswering;
      case 'wrongAddress':
        return context.tr.routeReasonWrongAddress;
      case 'refused':
        return context.tr.routeReasonRefused;
      default:
        return context.tr.routeReasonCantReach;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360.w,
      decoration: BoxDecoration(
        color: AppColors.brandBackground,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
        boxShadow: AppTextStyles.tripSheetShadow,
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Title & Subtitle
          Text(
            context.tr.routeWhatHappened,
            style: AppTextStyles.s24Bold12.copyWith(color: AppColors.brandBlack),
          ),
          SizedBox(height: 4.h),
          Text(
            context.tr.routeWillReviewOrder(widget.customerName, widget.companyName),
            style: AppTextStyles.s14Regular.copyWith(color: AppColors.textBody),
          ),
          SizedBox(height: 16.h),

          // 2. 2x2 Grid of Reason Tiles (explicit padding: EdgeInsets.zero removes GridView default top inset)
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reasons.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              mainAxisExtent: 104.h,
            ),
            itemBuilder: (context, index) {
              final reason = _reasons[index];
              final code = reason['code'] as String;
              final isSelected = _selectedCode == code;

              return InkWell(
                onTap: () {
                  if (code == 'notAnswering') {
                    widget.onCustomerNotAnsweringTapped();
                  } else {
                    setState(() {
                      _selectedCode = code;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(18.r),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.sliderProgressFill : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: isSelected ? AppColors.brandMain : AppColors.borderDeactivated,
                      width: isSelected ? 2.w : 1.w,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        reason['asset'] as String,
                        width: 24.w,
                        height: 24.h,
                      ),
                      Text(
                        _labelFor(context, code),
                        style: AppTextStyles.s14Bold14.copyWith(color: AppColors.brandBlack),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16.h),

          // 3. Note input field
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.deactivatedBadge,
              borderRadius: BorderRadius.circular(6.r), // Figma: note field radius 6
              border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr.routeAddNoteOptional,
                  style: AppTextStyles.s12Medium145.copyWith(color: AppColors.textBody),
                ),
                SizedBox(height: 2.h),
                TextField(
                  controller: _noteController,
                  style: AppTextStyles.s14Regular.copyWith(color: AppColors.brandBlack),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // 4. Send button
          SizedBox(
            height: 56.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedCode != null ? AppColors.brandMain : AppColors.deactivatedBadge,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                ),
              ),
              onPressed: _selectedCode != null
                  ? () {
                      final selected = _reasons.firstWhere((r) => r['code'] == _selectedCode);
                      widget.onSendToCompanyTapped(
                        _selectedCode!,
                        selected['label'] as String,
                      );
                    }
                  : null,
              child: Text(
                context.tr.routeSendToCompany(widget.companyName),
                style: AppTextStyles.s16Bold.copyWith(
                  color: _selectedCode != null ? AppColors.brandBlack : AppColors.textBody,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
