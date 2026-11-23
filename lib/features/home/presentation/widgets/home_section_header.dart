// lib/features/home/presentation/widgets/home_section_header.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// The bold 20/26 title every Home section opens with.
///
/// Shared so the four headings cannot drift apart. [trailing] covers the two
/// variants the design uses — the muted "Starts with your first shift" hint and
/// the "See all" action — instead of each section hand-rolling its own row.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    required this.title,
    super.key,
    this.trailing,
    this.onTrailingTap,
  });

  final String title;

  /// Optional muted label or action aligned to the start edge in RTL.
  final Widget? trailing;

  /// Invoked when [trailing] is tappable. Null leaves it as a plain label.
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.s12),
          if (onTrailingTap == null)
            trailing!
          else
            GestureDetector(
              onTap: onTrailingTap,
              // The row is otherwise non-interactive, so the detector would
              // otherwise contribute nothing to the semantics tree.
              behavior: HitTestBehavior.opaque,
              child: trailing!,
            ),
        ],
      ],
    );
  }
}
