// lib/features/route_fleet/presentation/widgets/delivery_illustration_view.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

class DeliveryIllustrationView extends StatelessWidget {
  const DeliveryIllustrationView({
    super.key,
    this.doorNumber,
    this.isFullFrame = true,
  });

  final String? doorNumber;
  final bool isFullFrame;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return CustomPaint(
          size: Size(w, h),
          painter: _IllustrationPainter(
            doorNumber: doorNumber,
            isFullFrame: isFullFrame,
            scaleX: w / (isFullFrame ? 412.0 : 360.0),
            scaleY: h / (isFullFrame ? 917.0 : 440.0),
          ),
        );
      },
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  _IllustrationPainter({
    required this.doorNumber,
    required this.isFullFrame,
    required this.scaleX,
    required this.scaleY,
  });

  final String? doorNumber;
  final bool isFullFrame;
  final double scaleX;
  final double scaleY;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Background Gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.photoBgGradientStart,
          AppColors.photoBgGradientEnd,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // 2. Floor
    final floorH = isFullFrame ? 202.0 * scaleY : 97.0 * scaleY;
    final floorPaint = Paint()..color = AppColors.photoFloor;
    canvas.drawRect(Rect.fromLTWH(0, h - floorH, w, floorH), floorPaint);

    // 3. Door
    final doorW = isFullFrame ? 190.0 * scaleX : 166.0 * scaleX;
    final doorH = isFullFrame ? 485.0 * scaleY : 273.0 * scaleY;
    final doorLeft = isFullFrame ? 173.0 * scaleX : 177.0 * scaleX - (26.0 * scaleX);
    final doorTop = isFullFrame ? 170.0 * scaleY : 262.0 * scaleY - (192.0 * scaleY);

    final doorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(doorLeft, doorTop, doorW, doorH),
      const Radius.circular(4),
    );

    // Frame Stroke around Door
    final framePaint = Paint()
      ..color = AppColors.photoDoorFrame
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0 * scaleX;
    canvas.drawRRect(doorRect, framePaint);

    // Door Fill
    final doorPaint = Paint()..color = AppColors.photoDoor;
    canvas.drawRRect(doorRect, doorPaint);

    // Knob Circle (10x10)
    final knobPaint = Paint()..color = AppColors.photoKnob;
    // Figma: the knob is on the LEFT side of the door (12 from the edge).
    final knobX = doorLeft + (17.0 * scaleX);
    final knobY = doorTop + (isFullFrame ? 234.0 * scaleY : 155.0 * scaleY);
    canvas.drawCircle(Offset(knobX, knobY), 5.0 * scaleX, knobPaint);

    // Door Number Plate (#F2F0EB 34x22 radius 3)
    if (doorNumber != null && doorNumber!.isNotEmpty) {
      final plateW = 34.0 * scaleX;
      final plateH = 22.0 * scaleY;
      final plateX = doorLeft + (doorW - plateW) / 2;
      final plateY = doorTop + (24.0 * scaleY);

      final plateRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(plateX, plateY, plateW, plateH),
        const Radius.circular(3),
      );
      final platePaint = Paint()..color = AppColors.photoDoorPlate;
      canvas.drawRRect(plateRRect, platePaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: doorNumber,
          style: TextStyle(
            fontFamily: AppFonts.fontFamilySatoshi,
            fontSize: 12.0 * scaleY,
            fontWeight: FontWeight.bold,
            color: AppColors.brandBlack,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final textX = plateX + (plateW - textPainter.width) / 2;
      final textY = plateY + (plateH - textPainter.height) / 2;
      textPainter.paint(canvas, Offset(textX, textY));
    }

    // 4. Package (#C79E6B radius 3) at the LEFT of the door, straddling the floor line.
    // Figma values: full frame 132x91 at (66, 605); photo frame 115x79 at (58, 288).
    final pkgW = (isFullFrame ? 132.0 : 115.0) * scaleX;
    final pkgH = (isFullFrame ? 91.0 : 79.0) * scaleY;
    final pkgX = (isFullFrame ? 66.0 : 58.0) * scaleX;
    final pkgY = (isFullFrame ? 605.0 : 288.0) * scaleY;

    final pkgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pkgX, pkgY, pkgW, pkgH),
      const Radius.circular(3),
    );
    final pkgPaint = Paint()..color = AppColors.photoPackage;
    canvas.drawRRect(pkgRRect, pkgPaint);

    // Tape (#DBBD8C full width x 6)
    final tapePaint = Paint()..color = AppColors.photoPackageTape;
    canvas.drawRect(
      Rect.fromLTWH(pkgX, pkgY + (isFullFrame ? 32.0 : 28.0) * scaleY, pkgW, 6.0 * scaleY),
      tapePaint,
    );

    // Label (#F7F7F2 radius 2): 48x25 (full frame) / 41x22 (photo frame)
    final labelW = (isFullFrame ? 48.0 : 41.0) * scaleX;
    final labelH = (isFullFrame ? 25.0 : 22.0) * scaleY;
    final labelRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        pkgX + (isFullFrame ? 73.0 : 63.0) * scaleX,
        pkgY + (isFullFrame ? 50.0 : 43.0) * scaleY,
        labelW,
        labelH,
      ),
      const Radius.circular(2),
    );
    final labelPaint = Paint()..color = AppColors.photoPackageLabel;
    canvas.drawRRect(labelRRect, labelPaint);
  }

  @override
  bool shouldRepaint(covariant _IllustrationPainter oldDelegate) =>
      oldDelegate.doorNumber != doorNumber ||
      oldDelegate.isFullFrame != isFullFrame ||
      oldDelegate.scaleX != scaleX ||
      oldDelegate.scaleY != scaleY;
}
