import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

/// Standard wide submit / call-to-action button for the app.
class RouteXMainButton extends StatefulWidget {
  const RouteXMainButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.leadingWidget,
    this.trailingWidget,
    this.height,
    this.width,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.textStyle,
    this.elevation = 0,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final double? height;
  final double? width;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final TextStyle? textStyle;
  final double elevation;

  @override
  State<RouteXMainButton> createState() => _RouteXMainButtonState();
}

class _RouteXMainButtonState extends State<RouteXMainButton> {
  /// Scale applied while the button is held down, for tactile feedback.
  static const double _pressedScale = 0.97;
  static const Duration _pressDuration = Duration(milliseconds: 120);

  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isLoading || widget.onPressed == null;
    final double buttonHeight = (widget.height ?? AppSizes.buttonH56).h;
    final double radius = (widget.borderRadius ?? AppSizes.r6).r;

    final button = Listener(
      onPointerDown: isDisabled ? null : (_) => _setPressed(true),
      onPointerUp: isDisabled ? null : (_) => _setPressed(false),
      onPointerCancel: isDisabled ? null : (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _isPressed ? _pressedScale : 1,
        duration: _pressDuration,
        curve: Curves.easeOut,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.backgroundColor ?? AppColors.brandMain,
              foregroundColor: widget.foregroundColor ?? AppColors.onBrand,
              disabledBackgroundColor:
                  widget.disabledBackgroundColor ??
                  (widget.backgroundColor ?? AppColors.brandMain).withValues(
                    alpha: 0.6,
                  ),
              disabledForegroundColor:
                  widget.disabledForegroundColor ??
                  AppColors.textButtonDisabled,
              elevation: widget.elevation,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
            onPressed: isDisabled ? null : widget.onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.leadingWidget != null) ...[
                  widget.leadingWidget!,
                  SizedBox(width: 8.w),
                ],
                Flexible(
                  child: Text(
                    widget.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style:
                        widget.textStyle ??
                        TextStyle(
                          fontFamily: AppFonts.fontFamilySatoshi,
                          fontFamilyFallback: AppFonts.fontFamilyFallback,
                          fontSize: AppFonts.size16.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.16,
                        ),
                  ),
                ),
                if (widget.trailingWidget != null) ...[
                  SizedBox(width: 8.w),
                  widget.trailingWidget!,
                ],
              ],
            ),
          ),
        ),
      ),
    );

    // Full-width buttons are the design's 360pt, centred on wider screens;
    // an explicit [RouteXMainButton.width] is left exactly as given.
    if (widget.width != null) return button;
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.controlW360),
        child: button,
      ),
    );
  }
}
