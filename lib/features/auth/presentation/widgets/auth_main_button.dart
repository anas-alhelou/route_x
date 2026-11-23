import 'package:flutter/material.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';

class AuthMainButton extends StatelessWidget {
  const AuthMainButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return RouteXMainButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }
}
