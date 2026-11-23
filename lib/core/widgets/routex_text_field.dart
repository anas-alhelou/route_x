import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/widgets/routex_form_scope.dart';

/// A reusable, labeled text field that follows the RouteX design system.
///
/// Reacts to focus state by highlighting borders and icons dynamically, and
/// renders validation feedback itself: the border and the existing prefix icon
/// turn red while the field is invalid, and the message is shown in a custom
/// row below the field (red dot + red text) instead of Flutter's built-in
/// error text, which is suppressed.
///
/// Errors are *submit-driven*: the validator only runs when the enclosing
/// `Form` is validated by the screen's action button. Inside a
/// [RouteXFormScope] the field also joins the form's shared error state, so
/// focusing **any** field of that form clears **all** of its errors, and typing
/// after that shows nothing again until the next button press.
class RouteXTextField extends StatefulWidget {
  const RouteXTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.contentPadding,
    this.enabled = true,
    this.tintPrefixIcon = true,
    this.tintSuffixIcon = true,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.labelStyle,
    this.labelInset = 0,
    this.textStyle,
    this.outlinedErrorIcon = false,
    this.inputFormatters,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool readOnly;
  final int maxLines;
  final int? minLines;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;
  final bool tintPrefixIcon;
  final bool tintSuffixIcon;
  final List<TextInputFormatter>? inputFormatters;

  /// When the field may run [validator] on its own, i.e. *before* the user has
  /// tried to submit the form.
  ///
  /// Defaults to [AutovalidateMode.disabled], which is what every form in the
  /// app wants: a field must never complain about its content before the user
  /// has tried to submit, and once the errors are gone they must stay gone
  /// until the next button press. The field deliberately does **not** escalate
  /// to [AutovalidateMode.onUserInteraction] after showing an error — that used
  /// to make a cleared error reappear on the very next keystroke.
  ///
  /// Keep it [AutovalidateMode.disabled] unless a field genuinely has to track
  /// its input continuously with no submit press to learn from.
  final AutovalidateMode autovalidateMode;

  /// Overrides the default 14 / medium label style.
  final TextStyle? labelStyle;

  /// Extra start inset of the label, for forms whose label sits inside the
  /// field's own edge.
  final double labelInset;

  /// Overrides the default 14 / regular style of the typed text and the hint.
  final TextStyle? textStyle;

  /// Shows the error message after a red outlined "!" circle instead of the
  /// default filled red badge.
  final bool outlinedErrorIcon;

  @override
  State<RouteXTextField> createState() => _RouteXTextFieldState();
}

class _RouteXTextFieldState extends State<RouteXTextField> {
  /// Collapses Flutter's built-in below-field error text; the message is
  /// rendered by [_buildErrorRow] instead. It stays in the semantics tree so
  /// screen readers still announce the validation failure.
  static const TextStyle _hiddenErrorStyle = TextStyle(
    fontSize: 0,
    height: 0,
    color: Colors.transparent,
  );

  late FocusNode _focusNode;

  /// The enclosing form's shared error state, when the field is inside a
  /// [RouteXFormScope]. Null keeps the field fully self-contained.
  RouteXFormController? _formController;

  /// Stable identity for this field's [_clearError] registration, so
  /// [RouteXFormController.unregister] can find it again.
  late final VoidCallback _clearErrorCallback = _clearError;

  /// Last validation error produced by [RouteXTextField.validator]; drives the
  /// red treatment and the message row.
  String? _errorText;

  /// Bumped on every clear, so a deferred validation write from before the
  /// clear can tell it is stale.
  int _clearGeneration = 0;

  bool get _hasError => _errorText != null;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resolved here rather than in initState: an inherited widget may only be
    // looked up once the element has a dependency on its parent.
    final scope = RouteXFormScope.maybeOf(context);
    if (identical(scope, _formController)) return;
    _formController?.unregister(_clearErrorCallback);
    _formController = scope;
    _formController?.register(_clearErrorCallback);
  }

  /// Drops this field's error without touching its value.
  ///
  /// Deliberately *not* `FormFieldState.reset()`, which would also clear the
  /// text the user typed — the opposite of what "they are fixing it now" means.
  ///
  /// The generation is bumped *before* the early return, not after: a
  /// validation can be in flight at the moment the field is focused, and that
  /// pending write is exactly the one that would otherwise put the error back.
  /// There is nothing to clear only if the write already landed, and in that
  /// case nothing is pending either.
  void _clearError() {
    _clearGeneration++;
    if (_errorText == null) return;
    setState(() => _errorText = null);
  }

  void _handleFocusChange() {
    // Gaining focus anywhere in the form clears every error it is showing: the
    // user is working on the form again, and a stale red row under a field they
    // are not even touching is noise at best and misleading at worst.
    if (_focusNode.hasFocus) {
      _formController?.clearAllErrors();
    }
    setState(() {});
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(value);
  }

  /// Mirrors the validation result into local state, since the field itself
  /// only surfaces the error text. The update is deferred to the next frame
  /// because validation also runs while the field builds.
  ///
  /// The [generation] guard makes a pending write a no-op once the field has
  /// been cleared in the meantime, so a validation that lands in the same frame
  /// as a focus change can never resurrect a message the user just dismissed.
  void _syncError(String? error) {
    if (error == _errorText) return;
    final generation = _clearGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _clearGeneration != generation) return;
      if (_errorText == error) return;
      setState(() => _errorText = error);
    });
  }

  @override
  void dispose() {
    _formController?.unregister(_clearErrorCallback);
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  /// The red dot + message shown below the field while it is invalid.
  Widget _buildErrorRow() {
    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.outlinedErrorIcon)
            Icon(Icons.error_outline, size: 16.sp, color: AppColors.textError)
          else
            Container(
              width: 16.w,
              height: 16.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.textError,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.priority_high,
                size: 12.sp,
                color: AppColors.brandWhite,
              ),
            ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              _errorText!,
              style: TextStyle(
                fontFamily: AppFonts.fontFamilySatoshi,
                fontFamilyFallback: AppFonts.fontFamilyFallback,
                fontSize: AppFonts.size12.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textError,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Single-line fields sit in a box of exactly 56pt (the design's input
  /// height, the same as the buttons) that draws the fill and the border
  /// itself; multi-line fields are returned untouched and grow with their text.
  Widget _fieldBox({
    required Widget child,
    required Color borderColor,
    required bool isFocused,
  }) {
    if (!_isSingleLine) return child;
    return Container(
      height: AppSizes.textFieldH56.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: widget.enabled ? borderColor : AppColors.surfaceEmpty,
          width: isFocused ? 1.5.w : 1.w,
        ),
      ),
      child: child,
    );
  }

  bool get _isSingleLine =>
      widget.obscureText || (widget.maxLines == 1 && widget.minLines == null);

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final hasError = _hasError;

    // Single rule shared by the border and the prefix icon: focus always wins,
    // so tapping back into an invalid field looks normal again and the red
    // treatment only returns once the field is left invalid.
    final borderColor = isFocused
        ? AppColors.brandMain
        : (hasError ? AppColors.textError : AppColors.borderDeactivated);
    final activeColor = isFocused
        ? AppColors.brandMain
        : (hasError ? AppColors.textError : AppColors.iconHint);
    final suffixColor = isFocused ? AppColors.brandMain : AppColors.iconHint;
    final fieldBorder = _border(borderColor, isFocused ? 1.5.w : 1.w);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppSizes.controlW360),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.labelText != null) ...[
            Padding(
              padding: EdgeInsetsDirectional.only(start: widget.labelInset.w),
              child: Text(
                widget.labelText!,
                style:
                    widget.labelStyle ??
                    TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontFamilyFallback: AppFonts.fontFamilyFallback,
                      fontSize: AppFonts.size14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.brandBlack,
                    ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
          _fieldBox(
            borderColor: borderColor,
            isFocused: isFocused,
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              textInputAction: widget.textInputAction,
              validator: (value) {
                final error = widget.validator?.call(value);
                if (error != null || _hasError) {
                  _syncError(error);
                }
                return error;
              },
              onChanged: _handleChanged,
              onFieldSubmitted: widget.onFieldSubmitted,
              readOnly: widget.readOnly,
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              minLines: widget.obscureText ? 1 : widget.minLines,
              enabled: widget.enabled,
              autovalidateMode: widget.autovalidateMode,
              style:
                  widget.textStyle ??
                  TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontFamilyFallback: AppFonts.fontFamilyFallback,
                    fontSize: AppFonts.size14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.brandBlack,
                  ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle:
                    widget.textStyle?.copyWith(color: AppColors.textGray) ??
                    TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontFamilyFallback: AppFonts.fontFamilyFallback,
                      fontSize: AppFonts.size14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGray,
                    ),
                // A single-line field draws its own 56pt box (see [build]) so the
                // height can never depend on how the decorator lays out; the
                // decorator itself then paints nothing.
                filled: !_isSingleLine,
                fillColor: AppColors.surfaceWhite,
                isCollapsed: _isSingleLine,
                contentPadding:
                    widget.contentPadding ??
                    EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: _isSingleLine ? 0 : 14.h,
                    ),

                // The message is rendered by [_buildErrorRow], so the built-in one
                // is collapsed (but kept for semantics).
                errorStyle: _hiddenErrorStyle,

                // The ColorFiltered override hack guarantees tint even within
                // padded constraints.
                prefixIcon: widget.prefixIcon != null
                    ? (widget.tintPrefixIcon
                          ? ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                activeColor,
                                BlendMode.srcIn,
                              ),
                              child: widget.prefixIcon,
                            )
                          : widget.prefixIcon)
                    : null,
                prefixIconConstraints: widget.prefixIcon != null
                    ? BoxConstraints(minWidth: 48.w, minHeight: 20.h)
                    : null,

                suffixIcon: widget.suffixIcon != null
                    ? (widget.tintSuffixIcon
                          ? ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                suffixColor,
                                BlendMode.srcIn,
                              ),
                              child: widget.suffixIcon,
                            )
                          : widget.suffixIcon)
                    : null,

                // Every border comes from the same rule, so Flutter's own
                // focus/error border selection can never disagree with it.
                border: _isSingleLine ? InputBorder.none : null,
                enabledBorder: _isSingleLine ? InputBorder.none : fieldBorder,
                focusedBorder: _isSingleLine ? InputBorder.none : fieldBorder,
                errorBorder: _isSingleLine ? InputBorder.none : fieldBorder,
                focusedErrorBorder: _isSingleLine
                    ? InputBorder.none
                    : fieldBorder,
                disabledBorder: _isSingleLine
                    ? InputBorder.none
                    : _border(AppColors.surfaceEmpty, 1.w),
              ),
            ),
          ),
          if (hasError) _buildErrorRow(),
        ],
      ),
    );
  }
}
