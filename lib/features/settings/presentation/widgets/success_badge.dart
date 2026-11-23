// lib/features/settings/presentation/widgets/success_badge.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/widgets/routex_pop_in.dart';

/// Green check illustration shown on the success screens (password updated,
/// report sent).
///
/// A PNG rendered from `success.svg`: that SVG fills a rect with an embedded
/// bitmap pattern, which flutter_svg does not draw.
class SuccessBadge extends StatelessWidget {
  const SuccessBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return RouteXPopIn(
      child: Assets.images.png.imgSuccess.image(width: 80.r, height: 81.r),
    );
  }
}
