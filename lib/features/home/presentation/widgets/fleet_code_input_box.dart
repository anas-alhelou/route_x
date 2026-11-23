// lib/features/home/presentation/widgets/fleet_code_input_box.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// One cell of the six-box code input.
///
/// Split out of `FleetCodeInputRow` so that file holds only behaviour — the
/// controllers, the focus chain and the paste fan-out — while this one holds only
/// how a single cell looks. The split is safe because the row keeps ownership of
/// [controller] and [focusNode]: this widget reads them and never replaces them,
/// so there is still exactly one source of truth for the row's plumbing.
class FleetCodeInputBox extends StatelessWidget {
  const FleetCodeInputBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.readOnly,
    required this.onChanged,
    required this.onTap,
  });

  /// This cell's single-character controller, owned by the row.
  final TextEditingController controller;

  /// This cell's focus node, owned by the row.
  final FocusNode focusNode;

  /// Renders the cell in the error style.
  final bool hasError;

  /// Blocks interaction while submitting.
  final bool readOnly;

  /// Reports the field's new contents.
  ///
  /// Receives the whole field text rather than the box index: the row decides
  /// whether that is a keystroke or a paste, because only the row knows which
  /// boxes follow this one.
  final ValueChanged<String> onChanged;

  /// Fired on tap, after the caret has been placed.
  final VoidCallback onTap;

  /// The border ink for the current state.
  ///
  /// Error wins over focus, focus over fill, fill over the resting hairline: a
  /// rejected code has to stay visibly rejected even while the driver is
  /// correcting it.
  Color get _borderColor {
    if (hasError) return AppColors.textError;
    if (focusNode.hasFocus) return AppColors.brandMain;
    if (controller.text.isNotEmpty) return AppColors.textPrimary;
    return AppColors.borderDeactivated;
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
          // The focused box thickens its border, which is how the design
          // distinguishes it once it also holds a character.
          width: focusNode.hasFocus ? AppSpacing.s2.w : AppSpacing.s1.w,
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
        style: AppTextStyles.codeBoxChar.copyWith(
          color: hasError ? AppColors.textError : AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        // Six, not one: a box must be able to *receive* a multi-character paste
        // so the row can fan it out across the remaining boxes. The framework
        // truncates the incoming string here first, so a long paste is already
        // capped before the row sees it.
        maxLength: 6,
        onChanged: onChanged,
        onTap: () {
          onTap();
          // Land the caret after the character rather than selecting it, so
          // typing replaces nothing and simply moves on.
          if (controller.text.isNotEmpty) {
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
          }
        },
      ),
    );
  }
}

/// Uppercases as the driver types, so the stored value is canonical even when it
/// comes from a keyboard or IME that does not honour `textCapitalization`.
///
/// The selection is carried across untouched: rebuilding the value without it
/// would collapse the caret to the start of the box on every keystroke.
class UpperCaseTextFormatter extends TextInputFormatter {
  /// Creates the formatter.
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.text == newValue.text.toUpperCase()
        ? newValue
        : newValue.copyWith(text: newValue.text.toUpperCase());
  }
}