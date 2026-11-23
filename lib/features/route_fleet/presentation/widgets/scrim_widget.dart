import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

class ScrimWidget extends StatelessWidget {
  const ScrimWidget({super.key, this.onTap, this.blur = true});

  final VoidCallback? onTap;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRect(
        child: BackdropFilter(
          filter: blur ? ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            color: AppColors.scrimWhite,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
