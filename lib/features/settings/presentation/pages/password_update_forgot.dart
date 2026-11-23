// lib/features/settings/presentation/pages/password_update_forgot.dart
import 'package:flutter/material.dart';
import 'password_update_page.dart';

/// Success screen at the end of the forgot-password flow started from
/// settings. Same design as after a regular change, so it reuses
/// [PasswordUpdatePage]; kept as its own entry point so the two flows can
/// diverge without touching each other.
class PasswordUpdateForgotPage extends StatelessWidget {
  const PasswordUpdateForgotPage({super.key, required this.email});

  /// Where the confirmation was sent.
  final String email;

  @override
  Widget build(BuildContext context) => PasswordUpdatePage(email: email);
}
