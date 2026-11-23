import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// Single cell of the 6-character company code input.
class CompanyCodeBox extends StatelessWidget {
  const CompanyCodeBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.readOnly,
    required this.onChanged,
    required this.onTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final bool readOnly;
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;

  Color get _borderColor {
    if (hasError) return AppColors.textError;
    if (focusNode.hasFocus) return AppColors.brandMain;
    if (controller.text.isNotEmpty) return AppColors.borderDeactivated;
    return AppColors.borderDeactivated;
  }

  double get _borderWidth {
    if (hasError) return AppSpacing.s1_5.w;
    if (focusNode.hasFocus) return AppSpacing.s2.w;
    return AppSpacing.s1.w;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.codeBoxW.w,
      height: AppSizes.codeBoxH.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSizes.r12.r),
        border: Border.all(
          color: _borderColor,
          width: _borderWidth,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
          const UpperCaseTextFormatter(),
        ],
        readOnly: readOnly,
        showCursor: !readOnly,
        cursorColor: AppColors.brandBlack,
        style: AppTextStyles.s24Bold.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        maxLength: 6,
        onChanged: onChanged,
        onTap: onTap,
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
