import 'dart:io';

import 'package:flutter/material.dart';

/// Shows a driver's profile picture from wherever it lives: an `http(s)` URL
/// (what the server returns), a file the driver just picked on this device, or
/// an app asset. An empty or missing [path] builds [placeholder].
class RouteXProfileImage extends StatelessWidget {
  const RouteXProfileImage({
    super.key,
    required this.path,
    required this.placeholder,
    this.fit = BoxFit.cover,
  });

  final String? path;
  final Widget placeholder;
  final BoxFit fit;

  static bool isUrl(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final value = path;
    if (value == null || value.isEmpty) return placeholder;
    Widget fallback(BuildContext _, Object __, StackTrace? ___) => placeholder;
    if (isUrl(value)) {
      return Image.network(
        value,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: fallback,
      );
    }
    if (value.startsWith('assets/')) {
      return Image.asset(
        value,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: fallback,
      );
    }
    return Image.file(
      File(value),
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: fallback,
    );
  }
}
