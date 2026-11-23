import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';

/// A circular avatar placeholder with a green "+" badge.
///
/// Manages image selection internally via [ImagePicker]:
///  - Tapping opens a bottom-sheet with Camera / Gallery options.
///  - On selection, [onImagePicked] is fired with the [File].
///  - The chosen photo is immediately rendered inside the circle.
class RouteXAvatarPicker extends StatelessWidget {
  const RouteXAvatarPicker({
    super.key,
    this.currentImage,
    this.diameter = 96,
    required this.onImageSourceSelected,
  });

  /// The currently selected profile image.
  final File? currentImage;

  final double diameter;

  /// Triggered with [true] for camera, [false] for gallery.
  final Function(bool isCamera) onImageSourceSelected;

  void _pickImage(BuildContext context, bool isCamera) {
    Navigator.of(context).pop(); // close BottomSheet first
    onImageSourceSelected(isCamera);
  }

  void _showImageSourceBottomSheet(BuildContext context) {
    showRoutexSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: AppSpacing.s12.h,
                  bottom: AppSpacing.s8.h,
                ),
                child: Container(
                  width: AppSpacing.s40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceEmpty,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s20.w,
                vertical: AppSpacing.s8.h,
              ),
              child: Text(
                context.tr.selectPhotoSource,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontFamilyFallback: AppFonts.fontFamilyFallback,
                  fontSize: AppFonts.size16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack,
                ),
              ),
            ),

            ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s20.w,
                vertical: AppSpacing.s4.h,
              ),
              leading: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.brandMain.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.brandMain,
                  size: AppFonts.size20.sp,
                ),
              ),
              title: Text(
                context.tr.camera,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontFamilyFallback: AppFonts.fontFamilyFallback,
                  fontSize: AppFonts.size14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textBlack,
                ),
              ),
              onTap: () => _pickImage(context, true),
            ),

            ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s20.sp,
                vertical: AppSpacing.s4.sp,
              ),
              leading: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.brandMain.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_library,
                  color: AppColors.brandMain,
                  size: AppFonts.size20.sp,
                ),
              ),
              title: Text(
                context.tr.gallery,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontFamilyFallback: AppFonts.fontFamilyFallback,
                  fontSize: AppFonts.size14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textBlack,
                ),
              ),
              onTap: () => _pickImage(context, false),
            ),

            SizedBox(height: AppSpacing.s16.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceBottomSheet(context),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // â”€â”€â”€ Avatar circle + badge â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          SizedBox(
            width: diameter.w,
            height: diameter.w,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(currentImage != null ? 4.r : 8.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: currentImage != null
                          ? AppColors.brandMain
                          : Colors.grey.shade300,
                      width: currentImage != null ? 2.w : 1.5.w,
                    ),
                  ),
                  child: ClipOval(
                    child: currentImage != null
                        ? Image.file(
                            currentImage!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            width: double.infinity,
                            height: double.infinity,
                            child: Assets.images.png.imgAvatarSolidPlaceholder
                                .image(),
                          ),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(
                          0xFF8CE000,
                        ), // Ø§Ù„Ù„ÙˆÙ† Ø§Ù„Ø£Ø®Ø¶Ø± Ø§Ù„Ù…Ø·Ø§Ø¨Ù‚ Ù„Ù„ØªØµÙ…ÙŠÙ…
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.add, color: AppColors.brandWhite, size: 22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          Text(
            currentImage == null ? context.tr.addPhoto : context.tr.changePhoto,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontFamilyFallback: AppFonts.fontFamilyFallback,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.brandBlack,
            ),
          ),
        ],
      ),
    );
  }
}

/// A custom painter that draws a dashed circular border.
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashes;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashes = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double dashAngle = (2 * math.pi) / (dashes * 2);

    for (int i = 0; i < dashes * 2; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        i * dashAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
