import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/widgets/routex_check_switcher.dart';

/// Live password-strength checklist mirroring [AuthValidators.validateStrongPassword]
/// (8 chars + upper + digit + symbol) so the UI and the domain rule
/// can never disagree.
class PasswordRequirementChecklist extends StatelessWidget {
  const PasswordRequirementChecklist({
    super.key,
    required this.hasMinLength,
    required this.hasCapital,
    required this.hasNumber,
    required this.hasSymbol,
    this.showTitle = true,
    this.rowSpacing = 10,
    this.labelSpacing = 8,
  });

  final bool hasMinLength;
  final bool hasCapital;
  final bool hasNumber;
  final bool hasSymbol;

  /// Whether to render the "Password requirements" heading above the rows.
  final bool showTitle;

  /// Vertical space between two requirement rows.
  final double rowSpacing;

  /// Horizontal space between a row's icon and its label.
  final double labelSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            context.tr.passwordRequirements,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontFamilyFallback: AppFonts.fontFamilyFallback,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
        ],
        _buildRequirementRow(context.tr.reqMinLength, hasMinLength),
        SizedBox(height: rowSpacing.h),
        _buildRequirementRow(context.tr.reqCapitalLetter, hasCapital),
        SizedBox(height: rowSpacing.h),
        _buildRequirementRow(context.tr.reqNumber, hasNumber),
        SizedBox(height: rowSpacing.h),
        _buildRequirementRow(context.tr.reqSymbol, hasSymbol),
      ],
    );
  }

  Widget _buildRequirementRow(String label, bool isMet) {
    return Row(
      children: [
        RouteXCheckSwitcher(
          child: Icon(
            isMet
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            key: ValueKey<bool>(isMet),
            size: 20.sp,
            color: isMet ? AppColors.brandMain : AppColors.textGray,
          ),
        ),
        SizedBox(width: labelSpacing.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontFamilyFallback: AppFonts.fontFamilyFallback,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.brandBlack,
            ),
          ),
        ),
      ],
    );
  }
}
