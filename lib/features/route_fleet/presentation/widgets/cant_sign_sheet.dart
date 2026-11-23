import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class CantSignSheet extends StatefulWidget {
  const CantSignSheet({
    super.key,
    this.initialReasonCode = 'handsFull',
    required this.onMarkDeliveredPhotoOnlyTapped,
    required this.onBackToSignatureTapped,
  });

  final String initialReasonCode;
  final ValueChanged<String> onMarkDeliveredPhotoOnlyTapped;
  final VoidCallback onBackToSignatureTapped;

  @override
  State<CantSignSheet> createState() => _CantSignSheetState();
}

class _CantSignSheetState extends State<CantSignSheet> {
  late String _selectedCode;

  final List<Map<String, String>> _reasons = const [
    {'code': 'refused'},
    {'code': 'handsFull'},
    {'code': 'buildingGuard'},
    {'code': 'somethingElse'},
  ];

  String _labelFor(BuildContext context, String code) {
    switch (code) {
      case 'refused':
        return context.tr.routeSignRefused;
      case 'handsFull':
        return context.tr.routeSignHandsFull;
      case 'buildingGuard':
        return context.tr.routeSignGuard;
      default:
        return context.tr.routeSignOther;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.initialReasonCode;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.brandBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r26)),
        boxShadow: AppTextStyles.proofSheetShadow,
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 34.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Grabber
          Center(
            child: Container(
              width: 36.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColors.borderDeactivated,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Title & Subtitle
          Text(
            context.tr.routeWhyCantSign,
            style: AppTextStyles.s22Bold115.copyWith(
              color: AppColors.brandBlack,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'The photo will be the proof for this delivery.',
            style: AppTextStyles.s14Regular.copyWith(color: AppColors.textBody),
          ),
          SizedBox(height: 14.h),

          // Radio Reasons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: _reasons.map((reason) {
              final isSelected = reason['code'] == _selectedCode;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCode = reason['code']!;
                    });
                  },
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.sliderProgressFill
                          : AppColors.canvas,
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.brandMain
                            : AppColors.borderDeactivated,
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          isSelected ? AppAssets.radioOn : AppAssets.radioOff,
                          width: 22.w,
                          height: 22.h,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          // Figma: one line (300 wide); shrink instead of cutting "...phone" off
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _labelFor(context, reason['code']!),
                              style: AppTextStyles.s15Bold.copyWith(
                                color: AppColors.brandBlack,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 14.h),

          // Mark delivered with photo only
          SizedBox(
            height: 56.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandMain,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                ),
              ),
              onPressed: () =>
                  widget.onMarkDeliveredPhotoOnlyTapped(_selectedCode),
              child: Text(
                context.tr.routeMarkDeliveredPhotoOnly,
                style: AppTextStyles.s16Bold.copyWith(
                  color: AppColors.brandBlack,
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Back to signature
          SizedBox(
            height: 44.h,
            child: TextButton(
              onPressed: widget.onBackToSignatureTapped,
              child: Text(
                context.tr.routeBackToSignature,
                style: AppTextStyles.s15SemiBold14.copyWith(
                  color: AppColors.brandBlack,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
