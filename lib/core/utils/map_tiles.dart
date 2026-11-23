import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

/// Inverts the light OSM tiles in dark mode (light mode renders them untouched).
Widget themedTileBuilder(BuildContext context, Widget tileWidget, TileImage tile) {
  if (!AppColors.isDark) return tileWidget;
  return ColorFiltered(
    colorFilter: const ColorFilter.matrix(<double>[
      -0.82, 0, 0, 0, 225, //
      0, -0.82, 0, 0, 225, //
      0, 0, -0.82, 0, 225, //
      0, 0, 0, 1, 0, //
    ]),
    child: tileWidget,
  );
}
