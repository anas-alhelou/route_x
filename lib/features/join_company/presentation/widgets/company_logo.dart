import 'package:flutter/material.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

/// A company's logo: a network image when [logo] is a URL, an asset when it is
/// an asset path, and a neutral building icon when there is none (or it
/// cannot be loaded), so no company ever shows another company's picture.
class CompanyLogoImage extends StatelessWidget {
  const CompanyLogoImage({
    super.key,
    required this.logo,
    required this.size,
    this.fit = BoxFit.contain,
  });

  final String logo;
  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final fallback = SizedBox(
      width: size,
      height: size,
      child: Icon(Icons.business, size: size * 0.6, color: AppColors.textGray),
    );
    if (logo.isEmpty) return fallback;
    final image = logo.startsWith('http')
        ? Image.network(
            logo,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (_, __, ___) => fallback,
          )
        : Image.asset(
            logo,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (_, __, ___) => fallback,
          );
    return image;
  }
}
