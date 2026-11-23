// lib/features/orders/presentation/widgets/history/proof_of_delivery_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../orders_today/orders_today_metrics.dart';
import 'history_metrics.dart';

/// One piece of proof: what it is, and the caption under it.
class ProofItem {
  const ProofItem({required this.caption, this.imageUrl});

  /// "Photo · 08:31 · 14 m away".
  final String caption;

  /// Null when the image is not available; the tile draws a stand-in.
  final String? imageUrl;
}

/// "PROOF OF DELIVERY" — the photo and the signature, side by side.
///
/// The answer to "I never got it", in the driver's pocket: where the
/// package was left, how close they were, and who signed.
class ProofOfDeliveryCard extends StatelessWidget {
  const ProofOfDeliveryCard({
    super.key,
    required this.label,
    this.photo,
    this.signature,
  });

  final String label;
  final ProofItem? photo;
  final ProofItem? signature;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    final signature = this.signature;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(HistoryMetrics.recordCardRadius.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.s10Bold.scaled.copyWith(
              height: 1.4,
              color: AppColors.textMuted,
              letterSpacing: 0.2.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Two fixed slots, so a lone photo keeps the same size it
              // would have beside a signature.
              Expanded(
                child: photo == null
                    ? const SizedBox.shrink()
                    : _ProofTile(
                        item: photo,
                        standIn: const _DoorstepStandIn(),
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: signature == null
                    ? const SizedBox.shrink()
                    : _ProofTile(
                        item: signature,
                        standIn: const _SignatureStandIn(),
                        fit: BoxFit.contain,
                        framed: true,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProofTile extends StatelessWidget {
  const _ProofTile({
    required this.item,
    required this.standIn,
    required this.fit,
    this.framed = false,
  });

  final ProofItem item;

  final Widget standIn;
  final BoxFit fit;

  /// A signature sits on paper, so it gets a border; a photo fills edge to
  /// edge.
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final url = item.imageUrl;
    final radius = BorderRadius.circular(12.r);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          image: true,
          label: item.caption,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceAction,
                borderRadius: radius,
                border: framed
                    ? Border.all(
                        color: AppColors.borderDeactivated,
                        width: 1.w,
                      )
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: url == null
                  ? standIn
                  : CachedNetworkImage(
                      imageUrl: url,
                      fit: fit,
                      errorWidget: (_, __, ___) => standIn,
                    ),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          item.caption,
          style: AppTextStyles.s12Medium.scaled
              .copyWith(height: 1.4, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

/// A package by a door — drawn while the real photo is unavailable, so the
/// tile still reads as "a photo of the doorstep".
class _DoorstepStandIn extends StatelessWidget {
  const _DoorstepStandIn();

  static const _wall = Color(0xFFCFCAC5);
  static const _floor = Color(0xFFA8A39C);
  static const _doorFrame = Color(0xFFF2EFEA);
  static const _door = Color(0xFF8C7A62);
  static const _box = Color(0xFFD2A46C);
  static const _tape = Color(0xFFE6C493);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) {
        final w = size.maxWidth;
        final h = size.maxHeight;
        return Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: _wall)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: h * 0.26,
              child: const ColoredBox(color: _floor),
            ),
            Positioned(
              left: w * 0.45,
              top: h * 0.05,
              width: w * 0.46,
              height: h * 0.76,
              child: Container(
                color: _doorFrame,
                padding: EdgeInsets.all(w * 0.02),
                child: const ColoredBox(color: _door),
              ),
            ),
            Positioned(
              left: w * 0.13,
              bottom: h * 0.1,
              width: w * 0.3,
              height: h * 0.28,
              child: Column(
                children: [
                  Expanded(flex: 2, child: Container(color: _box)),
                  Container(height: h * 0.025, color: _tape),
                  Expanded(flex: 5, child: Container(color: _box)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A signature stroke, drawn while the real image is unavailable.
class _SignatureStandIn extends StatelessWidget {
  const _SignatureStandIn();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SignaturePainter(), size: Size.infinite);
  }
}

class _SignaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = AppColors.brandBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(w * 0.15, h * 0.62)
      ..cubicTo(w * 0.2, h * 0.3, w * 0.24, h * 0.18, w * 0.28, h * 0.3)
      ..cubicTo(w * 0.31, h * 0.45, w * 0.28, h * 0.68, w * 0.31, h * 0.66)
      ..cubicTo(w * 0.36, h * 0.6, w * 0.38, h * 0.3, w * 0.42, h * 0.4)
      ..cubicTo(w * 0.45, h * 0.5, w * 0.44, h * 0.66, w * 0.48, h * 0.6)
      ..cubicTo(w * 0.52, h * 0.5, w * 0.55, h * 0.42, w * 0.58, h * 0.52)
      ..cubicTo(w * 0.6, h * 0.6, w * 0.62, h * 0.62, w * 0.66, h * 0.52)
      ..cubicTo(w * 0.7, h * 0.4, w * 0.76, h * 0.4, w * 0.79, h * 0.55)
      ..cubicTo(w * 0.8, h * 0.62, w * 0.83, h * 0.62, w * 0.86, h * 0.6);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) => false;
}
