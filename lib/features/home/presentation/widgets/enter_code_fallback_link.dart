// lib/features/home/presentation/widgets/enter_code_fallback_link.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// "Still stuck? Find a fleet instead" — a muted prompt and an underlined link,
/// the way out for a driver with no code at all.
///
/// Both halves are [Flexible] because the prompt is localized: an Arabic string
/// longer than its box would otherwise push the link off the edge of the screen.
/// Flexing them keeps the pair on one line and lets the longer one wrap, which
/// is preferable to truncating a sentence mid-word.
class EnterCodeFallbackLink extends StatelessWidget {
  const EnterCodeFallbackLink({
    super.key,
    required this.prompt,
    required this.label,
    required this.onTap,
  });

  /// Localized lead-in, e.g. "Still stuck?".
  final String prompt;

  /// Localized link text, e.g. "Find a fleet instead".
  final String label;

  /// Invoked when the link is pressed.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            prompt,
            style: AppTextStyles.footerLinkPrompt.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
        Flexible(
          child: TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              label,
              style: AppTextStyles.underlinedLink.copyWith(
                color: AppColors.brandMain,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.brandMain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
