import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_summary.dart';

/// The bordered logo box that fronts every fleet in the list.
///
/// Shared by the Home row, the Find a fleet card and the Go Online sheet's
/// request card, which differ only in size (40, 48 and 42pt respectively) and
/// would otherwise each carry their own copy of the same box, its tint and its
/// outline.
///
/// Picks its renderer from the logo's extension. Three of the fleet marks ship
/// as PNG exports and two are vector, and [Image.asset] renders neither SVG nor
/// a missing file gracefully — the latter throws into the console on every build
/// — so the branch keeps a missing mark rendering as an empty box instead.
class FleetAvatar extends StatelessWidget {
  const FleetAvatar({
    required this.fleet,
    super.key,
    this.size = AppSizes.avatarSm,
  });

  final FleetSummary fleet;

  /// Side length of the square. Home rows pass the 40pt default, the Find a
  /// fleet card [AppSizes.avatarMd] and the Go Online sheet
  /// [AppSizes.avatarRequest].
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: Color(fleet.avatarFill),
        borderRadius: BorderRadius.circular(AppSizes.r4.r),
        border: Border.all(color: Color(fleet.accentColor)),
      ),
      alignment: Alignment.center,
      child: _Logo(path: fleet.logoPath),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(path, fit: BoxFit.contain);
    }
    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}
