// lib/features/home/presentation/widgets/enter_code_title.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// The screen's two-tone heading: "Enter your" in ink, "fleet code" in the brand
/// colour.
///
/// Built as one [Text.rich] rather than two [Text]s so the two halves share a
/// line box. Two separate widgets on the same row would each wrap independently,
/// and a longer Arabic translation could break between them — which would read
/// as two headings instead of one sentence.
///
/// The second span restates the style rather than inheriting it, because
/// [TextSpan] children do not inherit from their parent and a bare
/// `TextSpan(text: ...)` would silently fall back to the ambient default.
class EnterCodeTitle extends StatelessWidget {
  const EnterCodeTitle({super.key, required this.leading, required this.accent});

  /// Localized first half, e.g. "Enter your".
  final String leading;

  /// Localized second half, e.g. "fleet code".
  final String accent;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: leading,
        style: AppTextStyles.codePageTitle.copyWith(
          color: AppColors.textPrimary,
        ),
        children: [
          TextSpan(
            text: accent,
            style: AppTextStyles.codePageTitle.copyWith(
              color: AppColors.brandMain,
            ),
          ),
        ],
      ),
    );
  }
}
