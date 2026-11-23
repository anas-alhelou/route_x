// lib/features/home/presentation/widgets/enter_code_entry.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/widgets/routex_shake.dart';
import 'package:routex_mobile/features/home/presentation/widgets/enter_code_caption_row.dart';
import 'package:routex_mobile/features/home/presentation/widgets/enter_code_error_line.dart';
import 'package:routex_mobile/features/home/presentation/widgets/fleet_code_input_row.dart';

/// The six boxes and the single line beneath them, inside the shake animation.
///
/// Grouped as one widget because the shake has to enclose the boxes *and* their
/// caption or error: the design shakes the whole group, and a shake applied to
/// the boxes alone would leave the caption stationary and visibly detached.
///
/// [code] is the BLoC's value, not a local copy. Nothing here holds state — the
/// row is fully controlled, so the page never needed a `GlobalKey` to reach into
/// it and can never disagree with what is on screen.
class EnterCodeEntry extends StatelessWidget {
  const EnterCodeEntry({
    super.key,
    required this.code,
    required this.isInvalid,
    required this.isSubmitting,
    required this.onCodeChanged,
    required this.onEditAttempted,
    required this.onPaste,
  });

  /// The code, owned by the BLoC.
  final String code;

  /// Whether to paint the error treatment and shake.
  final bool isInvalid;

  /// Whether to lock the boxes while a join is in flight.
  final bool isSubmitting;

  /// Reports a new code, from typing or an in-box paste.
  final ValueChanged<String> onCodeChanged;

  /// Fires when the driver touches a box on the invalid frame, so the error can
  /// be dismissed before they have typed anything.
  final VoidCallback? onEditAttempted;

  /// Reads the clipboard.
  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return RouteXShake(
      hasError: isInvalid,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FleetCodeInputRow(
            // Controlled: the row renders this value and reports changes. No key
            // is needed — nothing outside this widget reaches into the row's
            // State, which is what used to require a GlobalKey on the page.
            code: code,
            hasError: isInvalid,
            readOnly: isSubmitting,
            onChanged: onCodeChanged,
            onTap: onEditAttempted,
          ),
          SizedBox(height: AppSpacing.s12.h),
          // One of the two lines, never both: swapping rather than stacking keeps
          // the boxes from shifting as the error arrives.
          isInvalid
              ? EnterCodeErrorLine(message: tr.errFleetCodeInvalid)
              : EnterCodeCaptionRow(
                  caption: tr.enterFleetCodeCaption,
                  pasteLabel: tr.enterFleetCodePaste,
                  onPaste: onPaste,
                ),
        ],
      ),
    );
  }
}