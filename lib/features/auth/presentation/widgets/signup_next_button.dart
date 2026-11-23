import 'package:flutter/material.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';

/// Standard wide submit button for the Auth feature.
class SignupNextButton extends StatelessWidget {
  const SignupNextButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.label,
  });

  final bool isLoading;
  final VoidCallback? onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return RouteXMainButton(
      text: label ?? context.tr.next,
      isLoading: isLoading,
      onPressed: onPressed,
      height: 52,
    );
  }
}
