import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_colors_sync.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

enum SignatureMode { draw, type }

class DeliverySignatureView extends StatefulWidget {
  const DeliverySignatureView({
    super.key,
    required this.customerName,
    this.initialMode = SignatureMode.draw,
    required this.onBackToPhotoTapped,
    required this.onDoneTapped,
    required this.onCantSignTapped,
  });

  final String customerName;
  final SignatureMode initialMode;
  final VoidCallback onBackToPhotoTapped;
  final VoidCallback onDoneTapped;
  final VoidCallback onCantSignTapped;

  @override
  State<DeliverySignatureView> createState() => _DeliverySignatureViewState();
}

class _DeliverySignatureViewState extends State<DeliverySignatureView> {
  late SignatureMode _mode;
  late TextEditingController _nameController;
  final List<List<Offset>> _strokes = [];
  List<Offset>? _currentStroke;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _nameController = TextEditingController(text: widget.customerName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isDoneEnabled {
    final nameValid = _nameController.text.trim().isNotEmpty;
    if (_mode == SignatureMode.draw) {
      return nameValid && _strokes.isNotEmpty;
    } else {
      return nameValid;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(pageSystemUiOverlayStyle());

    final firstName = widget.customerName.split(' ').first;
    final isDraw = _mode == SignatureMode.draw;

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 26.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),

                    // 1. Back button ("Photo")
                    InkWell(
                      onTap: widget.onBackToPhotoTapped,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AppAssets.routeIcBackChevron,
                            width: 24.w,
                            height: 24.h,
                            colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            context.tr.routePhoto,
                            style: AppTextStyles.s15SemiBold.copyWith(
                              color: AppColors.brandBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // 2. Title & Subtitle
                    Text(
                      context.tr.routeAskToSign(firstName),
                      style: AppTextStyles.s28Bold115.copyWith(
                        color: AppColors.brandBlack,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      isDraw
                          ? context.tr.routeHandPhoneSign
                          : context.tr.routeHandPhoneType,
                      style: AppTextStyles.s14Regular.copyWith(
                        color: AppColors.textBody,
                      ),
                    ),
                    // Figma: P03 (Draw) 26, P03b (Type) 22
                    SizedBox(height: isDraw ? 26.h : 22.h),

                    // 3. Mode Switch (Draw vs Type)
                    Container(
                      height: 40.h,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppColors.deactivatedBadge,
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: RouteXTapScale(
                              onTap: () {
                                setState(() {
                                  _mode = SignatureMode.draw;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDraw
                                      ? AppColors.brandMain
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.r8,
                                  ),
                                  boxShadow: isDraw
                                      ? AppTextStyles.segmentShadow
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    context.tr.routeDraw,
                                    style: isDraw
                                        ? AppTextStyles.s14SemiBold.copyWith(
                                            color: AppColors.brandBlack,
                                          )
                                        : AppTextStyles.s14Medium145.copyWith(
                                            color: AppColors.textBody,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: RouteXTapScale(
                              onTap: () {
                                setState(() {
                                  _mode = SignatureMode.type;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !isDraw
                                      ? AppColors.brandMain
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.r8,
                                  ),
                                  boxShadow: !isDraw
                                      ? AppTextStyles.segmentShadow
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    context.tr.routeType,
                                    style: !isDraw
                                        ? AppTextStyles.s14SemiBold.copyWith(
                                            color: AppColors.brandBlack,
                                          )
                                        : AppTextStyles.s14Medium145.copyWith(
                                            color: AppColors.textBody,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Figma: P03 (Draw) 12, P03b (Type) 16
                    SizedBox(height: isDraw ? 12.h : 16.h),

                    // 4. Signature Pad (360 x 240)
                    Container(
                      width: double.infinity,
                      height: 240.h,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(AppSizes.r16),
                        border: Border.all(
                          color: AppColors.borderDeactivated,
                          width: 1.w,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          // Baseline (solid, 1.5, y=180 of 240) & cross mark (y=150)
                          Positioned(
                            left: 24.w,
                            right: 24.w,
                            top: 180.h,
                            child: Container(
                              height: 1.5.h,
                              color: AppColors.borderDeactivated,
                            ),
                          ),
                          Positioned(
                            left: 24.w,
                            top: 150.h,
                            child: Text(
                              '×',
                              style: AppTextStyles.s20Bold125.copyWith(
                                color: AppColors.textBody,
                              ),
                            ),
                          ),

                          // Pad Caption ("Sign here" / "Preview") at y=196
                          Positioned(
                            left: 24.w,
                            top: 196.h,
                            child: Text(
                              isDraw ? context.tr.routeSignHere : context.tr.routePreview,
                              style: AppTextStyles.s12Medium145.copyWith(
                                color: AppColors.textBody,
                              ),
                            ),
                          ),

                          // Draw Pad or Type Preview
                          if (isDraw)
                            GestureDetector(
                              onPanStart: (details) {
                                setState(() {
                                  _currentStroke = [details.localPosition];
                                  _strokes.add(_currentStroke!);
                                });
                              },
                              onPanUpdate: (details) {
                                setState(() {
                                  _currentStroke?.add(details.localPosition);
                                });
                              },
                              onPanEnd: (_) {
                                _currentStroke = null;
                              },
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: _SignatureStrokePainter(_strokes),
                              ),
                            )
                          else
                            Positioned.fill(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _nameController.text,
                                      style: AppTextStyles.s40MediumItalic
                                          .copyWith(
                                            color: AppColors.brandBlack,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Clear button in Draw mode
                          if (isDraw && _strokes.isNotEmpty)
                            Positioned(
                              top: 16.h,
                              right: 16.w,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _strokes.clear();
                                  });
                                },
                                borderRadius: BorderRadius.circular(
                                  AppSizes.r100,
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.deactivatedBadge,
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.r100,
                                    ),
                                  ),
                                  child: Text(
                                    context.tr.routeClear,
                                    style: AppTextStyles.s13SemiBold.copyWith(
                                      color: AppColors.brandBlack,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // 5. Signed by / Full name Field
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                        border: Border.all(
                          color: !isDraw
                              ? AppColors.brandBlack
                              : AppColors.borderDeactivated,
                          width: !isDraw ? 1.5.w : 1.w,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDraw ? context.tr.routeSignedBy : context.tr.routeFullName,
                            style: AppTextStyles.s12Medium145.copyWith(
                              color: AppColors.textBody,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          TextField(
                            controller: _nameController,
                            style: AppTextStyles.s16SemiBold.copyWith(
                              color: AppColors.brandBlack,
                            ),
                            cursorColor: AppColors.brandMain,
                            cursorWidth: 2,
                            cursorHeight: 20.h,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6.h),

                    // Helper Text
                    Text(
                      isDraw
                          ? context.tr.routeSomeoneElseCanSign
                          : context.tr.routePreviewUpdates,
                      style: AppTextStyles.s12Regular145.copyWith(
                        color: AppColors.textBody,
                      ),
                    ),
                    // Figma: Done sits at y=652 (buttons end at 760, 157 above the bottom edge)
                    SizedBox(height: 20.h),
                    const Spacer(),

                    // 6. Done · mark delivered button
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isDoneEnabled
                              ? AppColors.brandMain
                              : AppColors.deactivatedBadge,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.r8),
                          ),
                        ),
                        onPressed: _isDoneEnabled ? widget.onDoneTapped : null,
                        child: Text(
                          context.tr.routeDoneMarkDelivered,
                          style: AppTextStyles.s16Bold.copyWith(
                            color: _isDoneEnabled
                                ? AppColors.brandBlack
                                : AppColors.textBody,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // 7. They can't sign button
                    Center(
                      child: SizedBox(
                        height: 44.h,
                        child: TextButton(
                          onPressed: widget.onCantSignTapped,
                          child: Text(
                            context.tr.routeCantSign,
                            style: AppTextStyles.s15SemiBold14.copyWith(
                              color: AppColors.brandBlack,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 157.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignatureStrokePainter extends CustomPainter {
  _SignatureStrokePainter(this.strokes);

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brandBlack
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
