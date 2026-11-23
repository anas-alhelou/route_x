// lib/features/home/presentation/widgets/home_section_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';

/// The white rounded panel that every Home section sits in.
///
/// All three cards in the design are the same shape — 24pt radius, hairline
/// border, one soft drop shadow, 12/14/12/10 padding — so they share this shell
/// rather than repeating the decoration three times and letting the three drift
/// apart on the next design tweak.
class HomeSectionCard extends StatelessWidget {
  const HomeSectionCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsetsDirectional.fromSTEB(
      AppSpacing.s12,
      AppSpacing.s14,
      AppSpacing.s12,
      AppSpacing.s10,
    ),
    this.height,
  });

  /// The design's single depth cue, applied to every section card.
  ///
  /// [AppColors.shadowCard] is the fully opaque ink the shadow is mixed from; the
  /// 5% here is the alpha the design actually draws it at, so it cannot live in
  /// the token as a constant.
  static final List<BoxShadow> elevation = [
    BoxShadow(
      color: AppColors.shadowCard.withValues(alpha: 0.05),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Pins the panel to a declared height instead of letting it shrink-wrap.
  ///
  /// Only the Quick actions panel uses this — the design draws it at
  /// [AppSizes.quickActionsCardH] so its two rows sit centred in a fixed card
  /// rather than hugging the heading. The other cards are sized by their content
  /// and must stay null.
  final double? height;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: elevation,
      ),
      child: SizedBox(
        height: height?.h,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
