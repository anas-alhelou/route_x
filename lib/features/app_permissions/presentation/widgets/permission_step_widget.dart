// lib/features/app_permissions/presentation/widgets/permission_step_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import '../../domain/entities/permission_status_entity.dart';
import 'permission_indicator_dots.dart';

class PermissionStepWidget extends StatefulWidget {
  const PermissionStepWidget({
    super.key,
    required this.stepIndex,
    required this.status,
    required this.onAllowPressed,
    this.isLoading = false,
  });

  final int stepIndex; // 0: Location, 1: Notifications, 2: Gallery
  final PermissionStateStatus status;
  final VoidCallback onAllowPressed;
  final bool isLoading;

  @override
  State<PermissionStepWidget> createState() => _PermissionStepWidgetState();
}

class _PermissionStepWidgetState extends State<PermissionStepWidget>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _floatController;

  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    _entryController.forward();
  }

  @override
  void didUpdateWidget(covariant PermissionStepWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stepIndex != widget.stepIndex) {
      _entryController.reset();
      _entryController.forward();
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = _getTitle(context);
    final String description = _getDescription(context);
    final String buttonText = _getButtonText(context);

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 26.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              AnimatedBuilder(
                animation: _floatAnim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnim.value),
                    child: child,
                  );
                },
                child: SizedBox(
                  width: 237.w,
                  height: 219.h,
                  child: _getAssetWidget(),
                ),
              ),
              SizedBox(height: 48.h),
              // Figma: title block is a fixed 54 tall, 32 Bold, tracking 0.32.
              SizedBox(
                height: 54.h,
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontFamilyFallback: AppFonts.fontFamilyFallback,
                      fontSize: AppFonts.size32.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.32,
                      color: AppColors.brandBlack,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: _descriptionWidth().w,
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontFamilyFallback: AppFonts.fontFamilyFallback,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.14,
                    color: AppColors.brandBlack,
                    height: AppFonts.lineHeight14 / AppFonts.size14,
                  ),
                ),
              ),
              SizedBox(height: 68.h),
              PermissionIndicatorDots(currentIndex: widget.stepIndex),
              const Spacer(flex: 2),
              Padding(
                padding: EdgeInsets.only(bottom: 68.h),
                child: RouteXMainButton(
                  isLoading: widget.isLoading,
                  onPressed: widget.onAllowPressed,
                  text: buttonText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getAssetWidget() {
    switch (widget.stepIndex) {
      case 0:
        return Image.asset(
          'assets/images/png/location_ic.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.location_on, size: 80.sp, color: AppColors.brandMain),
        );
      case 1:
        return Image.asset(
          'assets/images/png/notification_ic.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.notifications, size: 80.sp, color: AppColors.brandMain),
        );
      case 2:
        return Image.asset(
          'assets/images/png/gallary_ic.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.photo_library, size: 80.sp, color: AppColors.brandMain),
        );
      default:
        return Image.asset(
          'assets/images/png/location_ic.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.location_on, size: 80.sp, color: AppColors.brandMain),
        );
    }
  }

  /// Width of the description block per Figma (360 / 345 / 316).
  double _descriptionWidth() {
    switch (widget.stepIndex) {
      case 1:
        return 345;
      case 2:
        return 316;
      default:
        return 360;
    }
  }

  String _getTitle(BuildContext context) {
    switch (widget.stepIndex) {
      case 0:
        return context.tr.permLocationTitle;
      case 1:
        return context.tr.permNotificationsTitle;
      case 2:
        return context.tr.permGalleryTitle;
      default:
        return '';
    }
  }

  String _getDescription(BuildContext context) {
    switch (widget.stepIndex) {
      case 0:
        return context.tr.permLocationBody;
      case 1:
        return context.tr.permNotificationsBody;
      case 2:
        return context.tr.permGalleryBody;
      default:
        return '';
    }
  }

  String _getButtonText(BuildContext context) {
    switch (widget.stepIndex) {
      case 0:
        return context.tr.permLocationButton;
      case 1:
        return context.tr.permNotificationsButton;
      case 2:
        return context.tr.permGalleryButton;
      default:
        return 'Allow access';
    }
  }
}
