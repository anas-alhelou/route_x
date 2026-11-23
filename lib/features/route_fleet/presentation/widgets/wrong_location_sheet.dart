// lib/features/route_fleet/presentation/widgets/wrong_location_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class WrongLocationSheet extends StatefulWidget {
  const WrongLocationSheet({
    super.key,
    required this.customerName,
    required this.onSendToDispatchTapped,
  });

  final String customerName;
  final void Function(String reasonCode, String reasonText) onSendToDispatchTapped;

  @override
  State<WrongLocationSheet> createState() => _WrongLocationSheetState();
}

class _WrongLocationSheetState extends State<WrongLocationSheet> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _reasons = const [
    {'code': 'entrance_elsewhere', 'text': 'Entrance is somewhere else'},
    {'code': 'wrong_street', 'text': 'Pin is on the wrong street'},
    {'code': 'address_not_exist', 'text': "Address doesn't exist"},
  ];

  String _labelFor(BuildContext context, String code) {
    switch (code) {
      case 'entrance_elsewhere':
        return context.tr.routeWrongEntrance;
      case 'wrong_street':
        return context.tr.routeWrongStreet;
      default:
        return context.tr.routeAddressMissing;
    }
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
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Overline
            Text(
              context.tr.routeWrongLocationFor(widget.customerName.toUpperCase()),
              style: AppTextStyles.s10Bold.copyWith(
                color: AppColors.textBody,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 10.h),

            // 2. Title (Figma R45: 22 Bold)
            Text(
              context.tr.routeWhatsWrongPin,
              style: AppTextStyles.s22Bold115.copyWith(color: AppColors.brandBlack),
            ),
            // Figma: 10 + a 2px spacer + 10 before the reasons
            SizedBox(height: 22.h),

            // 3. Radio rows
            ...List.generate(_reasons.length, (index) {
              final isSelected = _selectedIndex == index;
              final reason = _reasons[index];

              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: InkWell(
                  onTap: () => setState(() => _selectedIndex = index),
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.sliderProgressFill : AppColors.canvas,
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                      border: Border.all(
                        color: isSelected ? AppColors.brandMain : AppColors.borderDeactivated,
                        width: isSelected ? 2.w : 1.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _labelFor(context, reason['code']!),
                            style: AppTextStyles.s15SemiBold.copyWith(color: AppColors.brandBlack),
                          ),
                        ),
                        SvgPicture.asset(
                          isSelected ? AppAssets.radioOn : AppAssets.radioOff,
                          width: 22.w,
                          height: 22.h,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            // (each row already ends with the 10 gap Figma uses before the button)

            // 4. Primary Button
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
                onPressed: () {
                  final selected = _reasons[_selectedIndex];
                  widget.onSendToDispatchTapped(selected['code']!, selected['text']!);
                },
                child: Text(
                  context.tr.routeSendToDispatch,
                  style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
