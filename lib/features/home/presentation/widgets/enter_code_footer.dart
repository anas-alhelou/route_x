// lib/features/home/presentation/widgets/enter_code_footer.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/widgets/routex_primary_cta.dart';
import 'package:routex_mobile/core/widgets/routex_secondary_cta.dart';
import 'package:routex_mobile/features/home/presentation/widgets/enter_code_fallback_link.dart';

/// The sticky action block at the foot of the Enter Fleet Code screen.
///
/// One widget for two frames rather than two widgets, because the frames differ
/// only in which buttons they stack: the invalid frame adds a secondary action
/// and swaps which prompt sits above the fallback link. Both share the same
/// padding, the same button order and the same link, and duplicating that would
/// be how the two frames drift apart later.
///
/// Owns no state. Every label is passed in already localized, and every action is
/// a callback, so this file is the whole of the footer's behaviour and the page
/// stays free of layout.
class EnterCodeFooter extends StatelessWidget {
  const EnterCodeFooter({
    super.key,
    required this.isInvalid,
    required this.isLoading,
    required this.canSubmit,
    required this.tryAgainLabel,
    required this.askManagerLabel,
    required this.joinLabel,
    required this.stillStuckPrompt,
    required this.lostCodePrompt,
    required this.findFleetLabel,
    required this.onTryAgain,
    required this.onAskManager,
    required this.onSubmit,
    required this.onFindFleet,
  });

  /// Whether the last attempt was rejected; selects the frame.
  final bool isInvalid;

  /// Whether a verification is in flight; shows the primary button's spinner.
  final bool isLoading;

  /// Whether the code is complete enough to submit.
  ///
  /// Passed separately from [isLoading] because the button must be *disabled*
  /// when the code is incomplete, which is a different visual state from
  /// "showing a spinner".
  final bool canSubmit;

  /// Localized label of the invalid frame's primary action.
  final String tryAgainLabel;

  /// Localized label of the invalid frame's secondary action.
  final String askManagerLabel;

  /// Localized label of the default frame's primary action.
  final String joinLabel;

  /// Localized lead-in above the link on the invalid frame.
  final String stillStuckPrompt;

  /// Localized lead-in above the link on the default frame.
  final String lostCodePrompt;

  /// Localized link text, shared by both frames.
  final String findFleetLabel;

  /// Empties the boxes and focuses the first one.
  final VoidCallback onTryAgain;

  /// Opens the contact-manager flow.
  final VoidCallback onAskManager;

  /// Starts verification.
  final VoidCallback onSubmit;

  /// Leaves for Find a fleet.
  final VoidCallback onFindFleet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Directional: the page gutter has to mirror on an Arabic device.
      padding: EdgeInsetsDirectional.fromSTEB(
        AppSizes.p24.w,
        AppSpacing.s16.h,
        AppSizes.p24.w,
        AppSpacing.s16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isInvalid) ...[
            RouteXPrimaryCta(
              label: tryAgainLabel,
              showArrow: true,
              onPressed: onTryAgain,
            ),
            SizedBox(height: AppSpacing.s10.h),
            RouteXSecondaryCta(
              label: askManagerLabel,
              showTrailingArrow: true,
              onPressed: onAskManager,
            ),
            SizedBox(height: AppSpacing.s14.h),
            EnterCodeFallbackLink(
              prompt: stillStuckPrompt,
              label: findFleetLabel,
              onTap: onFindFleet,
            ),
          ] else ...[
            RouteXPrimaryCta(
              label: joinLabel,
              showArrow: true,
              isLoading: isLoading,
              onPressed: canSubmit ? onSubmit : null,
            ),
            SizedBox(height: AppSpacing.s14.h),
            EnterCodeFallbackLink(
              prompt: lostCodePrompt,
              label: findFleetLabel,
              onTap: onFindFleet,
            ),
          ],
        ],
      ),
    );
  }
}
