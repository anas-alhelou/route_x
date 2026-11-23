// lib/features/home/presentation/widgets/enter_code_error_line.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// The single line of red text that stands in for the format caption once a code
/// has been rejected.
///
/// Sits where [EnterCodeCaptionRow] normally is rather than below it, so the
/// boxes do not shift down when the error arrives — a layout jump at the moment
/// the driver is reading the message would move the text they are reading.
///
/// Takes the already-localized message rather than a failure or a key: by the
/// time this is built the BLoC has failed, and translating in a widget would put
/// a `context.tr` lookup in a leaf that has no other reason to know about
/// locales.
class EnterCodeErrorLine extends StatelessWidget {
  const EnterCodeErrorLine({super.key, required this.message});

  /// Localized reason the code was rejected.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: AppTextStyles.s12Regular.copyWith(color: AppColors.textError),
    );
  }
}
