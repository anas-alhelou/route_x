// lib/features/orders/presentation/widgets/offers/order_offer_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../orders_today/orders_today_metrics.dart';

/// `09:42` — minutes and seconds left, never negative.
String offerClock(Duration left) {
  final total = left.isNegative ? 0 : left.inSeconds;
  final minutes = (total ~/ 60).toString().padLeft(2, '0');
  final seconds = (total % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

enum OfferPillTone {
  /// The running timer — green, still answerable.
  live,

  /// "Time's up", "No longer available" — grey, nothing to do.
  ended,

  /// The fleet tag.
  neutral,

  /// "+2.4 km · +12 min to your route" — blue, information only.
  info,
}

/// A rounded tag with an optional status dot — the timer, the fleet, the
/// route impact.
class OfferPill extends StatelessWidget {
  const OfferPill({
    super.key,
    required this.label,
    this.tone = OfferPillTone.neutral,
    this.dot = true,
  });

  final String label;
  final OfferPillTone tone;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color? border, Color ink, Color dotColor) =
        switch (tone) {
      OfferPillTone.live => (
          AppColors.iconBrand,
          AppColors.brandMain,
          AppColors.brandMain,
          AppColors.brandMain,
        ),
      OfferPillTone.ended => (
          AppColors.canvas,
          null,
          AppColors.brandBlack,
          AppColors.textMuted,
        ),
      OfferPillTone.neutral => (
          AppColors.canvas,
          AppColors.borderDeactivated,
          AppColors.brandBlack,
          AppColors.brandMain,
        ),
      OfferPillTone.info => (
          AppColors.surfaceWhite,
          AppColors.iconBlueAccent,
          AppColors.iconBlueAccent,
          AppColors.iconBlueAccent,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
        border: border == null ? null : Border.all(color: border, width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6.w,
              height: 6.w,
              decoration:
                  BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            SizedBox(width: 6.w),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.s12Bold.scaled
                  .copyWith(height: 1.35, color: ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// White card with the hairline border every Orders card uses.
class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ??
          EdgeInsets.symmetric(horizontal: 21.w, vertical: 19.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(OrdersTodayMetrics.cardRadius.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
      ),
      child: child,
    );
  }
}

/// A rounded green square holding a black icon — the details rows and the
/// end states.
class OfferIconWell extends StatelessWidget {
  const OfferIconWell({super.key, required this.child, this.size = 36});

  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: AppColors.brandMain,
        borderRadius: BorderRadius.circular((size * 0.28).r),
      ),
      child: Center(child: child),
    );
  }
}

class OfferDetailItem {
  const OfferDetailItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Widget icon;
  final String title;
  final String subtitle;
}

/// Where, when and what — three rows, each a green icon well and two lines.
class OfferDetailsCard extends StatelessWidget {
  const OfferDetailsCard({super.key, required this.items});

  final List<OfferDetailItem> items;

  @override
  Widget build(BuildContext context) {
    return OfferCard(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: Divider(
                  height: 1.h,
                  thickness: 1.h,
                  color: AppColors.borderDeactivated,
                ),
              ),
            Row(
              children: [
                OfferIconWell(child: items[i].icon),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[i].title,
                        style: AppTextStyles.s14Bold.scaled.copyWith(
                          fontSize: 15.sp,
                          height: 1.35,
                          color: AppColors.brandBlack,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        items[i].subtitle,
                        style: AppTextStyles.s14Regular.scaled.copyWith(
                          fontSize: 13.sp,
                          height: 1.35,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The icons the details card and end states use, in near-black.
abstract final class OfferIcons {
  static Widget pin() => Icon(
        Icons.location_on_outlined,
        size: 22.w,
        color: AppColors.brandBlack,
      );

  static Widget timer({double size = 22}) => Assets.icons.svg.timer.svg(
        width: size.w,
        height: size.w,
        colorFilter:
            ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
      );

  static Widget package({double size = 22}) => Assets.icons.svg.package.svg(
        width: size.w,
        height: size.w,
        colorFilter:
            ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
      );
}

/// "NOTE FROM YOUR COMPANY" — amber, the one thing to read before going.
class OfferNoteCard extends StatelessWidget {
  const OfferNoteCard({super.key, required this.label, required this.note});

  final String label;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 19.h),
      decoration: BoxDecoration(
        color: AppColors.statusAmberSurface,
        borderRadius: BorderRadius.circular(OrdersTodayMetrics.cardRadius.r),
        border: Border.all(color: AppColors.statusAmber, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.s10Bold.scaled.copyWith(
              height: 1.35,
              letterSpacing: 0.8.sp,
              color: AppColors.statusAmber,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            note,
            style: AppTextStyles.s14Regular.scaled
                .copyWith(height: 1.35, color: AppColors.brandBlack),
          ),
        ],
      ),
    );
  }
}

/// A group's totals — "3 stops added · +6.8 km to your route · +36 min".
class OfferGroupSummary extends StatelessWidget {
  const OfferGroupSummary({super.key, required this.stats});

  /// (value, label) pairs.
  final List<(String, String)> stats;

  @override
  Widget build(BuildContext context) {
    return OfferCard(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 17.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < stats.length; i++)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      stats[i].$1,
                      style: AppTextStyles.s20Bold.scaled.copyWith(
                        height: 1.35,
                        color: AppColors.brandMain,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    stats[i].$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.s12Regular.scaled.copyWith(
                      height: 1.35,
                      color: AppColors.brandBlack,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One order of a group, with the checkbox that leaves it out.
class OfferOrderRow extends StatelessWidget {
  const OfferOrderRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.packages,
    required this.skipped,
    required this.skippingLabel,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String distance;
  final String packages;
  final bool skipped;
  final String skippingLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ink = skipped ? AppColors.textMuted : AppColors.brandBlack;

    return Semantics(
      checked: !skipped,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 14.h),
          child: Row(
            children: [
              _Checkbox(on: !skipped),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.s14Bold.scaled.copyWith(
                        fontSize: 15.sp,
                        height: 1.35,
                        color: ink,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.s14Regular.scaled.copyWith(
                        fontSize: 13.sp,
                        height: 1.35,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    skipped ? skippingLabel : distance,
                    style: AppTextStyles.s14Bold.scaled.copyWith(
                      fontSize: 13.sp,
                      height: 1.35,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    packages,
                    style: AppTextStyles.s12Regular.scaled.copyWith(
                      height: 1.35,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final size = 26.w;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: on ? AppColors.brandMain : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: on
            ? null
            : Border.all(color: AppColors.borderDeactivated, width: 1.5.w),
      ),
      child: on
          ? Icon(Icons.check_rounded, size: 20.w, color: AppColors.brandBlack)
          : null,
    );
  }
}

/// Takes the buttons' place once the offer can no longer be answered:
/// a green icon well, a title and the sentence under it.
class OfferEndedNote extends StatelessWidget {
  const OfferEndedNote({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final Widget icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OfferIconWell(size: 44, child: icon),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.s16Bold.scaled.copyWith(
                    fontSize: 18.sp,
                    height: 1.35,
                    color: AppColors.brandBlack,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  message,
                  style: AppTextStyles.s14Regular.scaled.copyWith(
                    height: 1.35,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Couldn't accept. You're offline." — red, the offer still open.
class OfferErrorCard extends StatelessWidget {
  const OfferErrorCard({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: AppColors.iconWarning,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.iconRed, width: 1.w),
        ),
        child: Row(
          children: [
            Assets.icons.svg.offline.svg(
              width: 24.w,
              height: 24.w,
              colorFilter:
                  const ColorFilter.mode(AppColors.iconRed, BlendMode.srcIn),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.s14Bold.scaled.copyWith(
                      fontSize: 14.sp,
                      height: 1.35,
                      color: AppColors.iconRed,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    message,
                    style: AppTextStyles.s12Regular.scaled.copyWith(
                      height: 1.35,
                      color: AppColors.brandBlack,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Red, filled, 56 tall — "Decline" next to the green primary.
class OfferDeclineButton extends StatelessWidget {
  const OfferDeclineButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: enabled ? AppColors.iconRed : AppColors.surfaceEmpty,
      borderRadius: BorderRadius.circular(8.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 56.h,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              style: AppTextStyles.s16Bold.scaled.copyWith(
                fontSize: 16.sp,
                height: 1.35,
                color: enabled ? AppColors.surfaceWhite : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A sketch of the route near the offered stop — streets, the green line
/// from the stop it would follow, and the offered stop joined to it — until
/// a real map is wired in. [faded] once the offer can no longer be taken.
class OfferMapPreview extends StatelessWidget {
  const OfferMapPreview({
    super.key,
    required this.afterStop,
    this.streetName,
    this.faded = false,
  });

  /// The stop the offered order would follow.
  final int afterStop;

  /// A street to label, `Quraish St`; null draws none.
  final String? streetName;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(OrdersTodayMetrics.cardRadius.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _OfferRouteMapPainter(
          afterStop: afterStop,
          streetName: streetName,
          faded: faded,
        ),
      ),
    );
  }
}

class _OfferRouteMapPainter extends CustomPainter {
  const _OfferRouteMapPainter({
    required this.afterStop,
    required this.streetName,
    required this.faded,
  });

  final int afterStop;
  final String? streetName;
  final bool faded;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = AppColors.isDark
            ? const Color(0xFF1A1E16)
            : const Color(0xFFF1F2EE),
    );

    final blockPaint = Paint()
      ..color = AppColors.isDark
          ? const Color(0xFF22271D)
          : const Color(0xFFE6E7E2);
    final roadPaint = Paint()
      ..color = AppColors.isDark
          ? const Color(0xFF2E3428)
          : AppColors.brandWhite
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    const verticalStreets = [0.17, 0.39, 0.61, 0.82];
    const horizontalStreets = [0.17, 0.66];
    for (var column = 0; column <= verticalStreets.length; column++) {
      final left = column == 0 ? 0.0 : verticalStreets[column - 1];
      final right =
          column == verticalStreets.length ? 1.0 : verticalStreets[column];
      for (var row = 0; row <= horizontalStreets.length; row++) {
        final top = row == 0 ? 0.0 : horizontalStreets[row - 1];
        final bottom =
            row == horizontalStreets.length ? 1.0 : horizontalStreets[row];
        final rect = Rect.fromLTRB(
          left * size.width + 10,
          top * size.height + 10,
          right * size.width - 10,
          bottom * size.height - 10,
        );
        if (rect.width <= 0 || rect.height <= 0) continue;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          blockPaint,
        );
      }
    }

    final streets = Path();
    for (final x in verticalStreets) {
      streets
        ..moveTo(x * size.width, 0)
        ..lineTo(x * size.width, size.height);
    }
    for (final y in horizontalStreets) {
      streets
        ..moveTo(0, y * size.height)
        ..lineTo(size.width, y * size.height);
    }
    canvas.drawPath(streets, roadPaint);

    final name = streetName;
    if (name != null) {
      final label = TextPainter(
        text: TextSpan(
          text: name,
          style: TextStyle(
            fontFamily: AppFonts.fontFamilySatoshi,
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(size.width * 0.47, size.height * 0.17 - 2));
    }

    // The route from the stop the offer follows: down, across, and on.
    final stop = Offset(size.width * 0.39, size.height * 0.30);
    final route = Path()
      ..moveTo(stop.dx, stop.dy)
      ..lineTo(stop.dx, size.height * 0.66)
      ..lineTo(size.width * 0.82, size.height * 0.66)
      ..lineTo(size.width * 0.82, size.height * 1.05);
    final routeColor = faded
        ? AppColors.brandMain.withValues(alpha: 0.45)
        : AppColors.brandMain;
    canvas
      ..drawPath(
        route,
        Paint()
          ..color = faded
              ? const Color(0x335D9900)
              : const Color(0xFF5D9900)
          ..strokeWidth = 9
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
      )
      ..drawPath(
        route,
        Paint()
          ..color = routeColor
          ..strokeWidth = 6
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
      );

    // The offered stop, joined to the stop it would follow.
    final offered = Offset(size.width * 0.18, size.height * 0.73);
    final link = Path()
      ..moveTo(offered.dx, offered.dy)
      ..quadraticBezierTo(
        size.width * 0.33,
        size.height * 0.66,
        stop.dx,
        stop.dy + 18,
      );
    final dash = Paint()
      ..color = faded ? AppColors.textMuted : AppColors.brandBlack
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final metric in link.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + 4).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), dash);
        distance = end + 3;
      }
    }

    // Stop [afterStop]: white with a grey ring.
    canvas
      ..drawCircle(stop, 18, Paint()..color = AppColors.borderSubtle)
      ..drawCircle(stop, 16.5, Paint()..color = AppColors.brandWhite);
    final number = TextPainter(
      text: TextSpan(
        text: '$afterStop',
        style: TextStyle(
          fontFamily: AppFonts.fontFamilySatoshi,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: faded ? AppColors.textMuted : AppColors.brandBlack,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    number.paint(canvas, stop - Offset(number.width / 2, number.height / 2));

    // The offered stop: green with a package.
    canvas
      ..drawCircle(offered, 19, Paint()..color = AppColors.brandWhite)
      ..drawCircle(offered, 17, Paint()..color = routeColor);
    const icon = Icons.inventory_2_outlined;
    final glyph = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: 18,
          color: faded ? AppColors.textMuted : AppColors.brandBlack,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    glyph.paint(canvas, offered - Offset(glyph.width / 2, glyph.height / 2));
  }

  @override
  bool shouldRepaint(covariant _OfferRouteMapPainter old) =>
      old.afterStop != afterStop ||
      old.streetName != streetName ||
      old.faded != faded;
}
