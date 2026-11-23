import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// The app's one search bar: 56pt tall, at most 360pt wide (centred on wider
/// screens), 6pt corners, a hairline border that turns brand-coloured on focus,
/// a search glyph at the start and an optional [trailing] widget at the end.
///
/// The box is drawn here rather than by the text field's decorator, so the
/// height is exactly 56 whatever the font or the icons are.
///
/// When [showClearButton] is set, a clear (×) button appears while the field
/// has text and, once tapped, empties it and reports `''` through [onChanged].
class RouteXSearchField extends StatefulWidget {
  const RouteXSearchField({
    required this.hintText,
    required this.onChanged,
    this.controller,
    this.focusNode,
    this.initialValue = '',
    this.autofocus = false,
    this.showClearButton = false,
    this.trailing,
    super.key,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  /// Owned by the caller when given; otherwise the field creates its own.
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Seeds an internally created controller once; ignored when [controller]
  /// is supplied.
  final String initialValue;

  final bool autofocus;
  final bool showClearButton;

  /// Shown at the end of the bar, e.g. the Find-a-fleet filter glyph.
  final Widget? trailing;

  @override
  State<RouteXSearchField> createState() => _RouteXSearchFieldState();
}

class _RouteXSearchFieldState extends State<RouteXSearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController(text: widget.initialValue);
  bool _focused = false;

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _focused
        ? AppColors.borderActive
        : AppColors.borderDeactivated;

    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.controlW360),
        child: Container(
          height: AppSizes.textFieldH56.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppSizes.r6.r),
            border: Border.all(
              color: borderColor,
              width: _focused ? 1.5.w : 1.w,
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 16.w),
              SvgPicture.asset(
                AppAssets.icSearch,
                width: AppSizes.iconSm.w,
                height: AppSizes.iconSm.w,
                colorFilter: ColorFilter.mode(
                  AppColors.textMuted,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Focus(
                  onFocusChange: (focused) =>
                      setState(() => _focused = focused),
                  child: TextField(
                    controller: _controller,
                    focusNode: widget.focusNode,
                    autofocus: widget.autofocus,
                    onChanged: widget.onChanged,
                    textInputAction: TextInputAction.search,
                    textAlignVertical: TextAlignVertical.center,
                    style: AppTextStyles.s14Regular.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: widget.hintText,
                      hintStyle: AppTextStyles.s14Regular.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.showClearButton)
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) => _controller.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          onPressed: _clear,
                          icon: Icon(
                            Icons.close_rounded,
                            size: AppSizes.iconSm.w,
                            color: AppColors.textMuted,
                          ),
                        ),
                ),
              if (widget.trailing != null) ...[
                SizedBox(width: 12.w),
                widget.trailing!,
                SizedBox(width: 16.w),
              ] else
                SizedBox(width: 16.w),
            ],
          ),
        ),
      ),
    );
  }
}
