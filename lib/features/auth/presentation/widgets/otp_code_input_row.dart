import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

/// Six-box OTP input enforcing left-to-right layout. Owns one
/// [TextEditingController] per box, auto-advances focus, supports pasting up
/// to six digits, and reports the combined code through [onChanged].
///
/// ## Backspace
///
/// Every box except the first holds an invisible zero-width sentinel while it
/// is empty. That gives an Android soft keyboard something to delete, so
/// backspace on an empty box arrives as an ordinary text change (a soft
/// keyboard sends no key event for it, and a text field with no text produces
/// no change at all). Hardware keyboards are handled by the focus node's key
/// handler. Both paths do the same thing in ONE press:
///
/// * box with a digit: the digit is cleared, focus stays;
/// * empty box: the previous digit is cleared and focus moves back to it.
class OtpCodeInputRow extends StatefulWidget {
  const OtpCodeInputRow({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hasError = false,
    this.readOnly = false,
    this.onTap,
    this.resetEpoch = 0,
  });

  /// Parent controller mirroring the joined six-digit code.
  final TextEditingController controller;

  /// Reports the current joined code after any box changes.
  final ValueChanged<String> onChanged;

  /// When true, boxes and digits render in the error (red) style.
  final bool hasError;

  /// Blocks every input interaction: no typing, no paste, no autofill.
  ///
  /// Set while a verification is in flight or already accepted. The code has
  /// been sent (and is single-use), so letting the boxes change again could only
  /// produce a duplicate submission.
  final bool readOnly;

  /// Optional callback fired when any box is tapped.
  final VoidCallback? onTap;

  /// Whenever this value changes the boxes are cleared and the first one gains
  /// focus. Does not call [onChanged].
  final int resetEpoch;

  @override
  State<OtpCodeInputRow> createState() => _OtpCodeInputRowState();
}

class _OtpCodeInputRowState extends State<OtpCodeInputRow> {
  /// Zero-width space held by empty boxes (see the class docs).
  static const String _sentinel = '\u200B';

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  /// The digit each box currently holds, `''` when empty.
  final List<String> _digits = List.filled(6, '');

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onParentControllerChanged);
    for (int i = 0; i < 6; i++) {
      _writeBox(i, '');
      _focusNodes[i].addListener(() {
        if (mounted) setState(() {}); // Rebuild for active outline colors
      });
      // Hardware backspace on an empty box: delete the previous digit and move
      // there in the same press.
      _focusNodes[i].onKeyEvent = (node, event) {
        if (!widget.readOnly &&
            event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _digits[i].isEmpty &&
            i > 0) {
          _deletePreviousAndFocus(i);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
  }

  @override
  void didUpdateWidget(OtpCodeInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetEpoch != widget.resetEpoch) {
      _clearAll();
      // After the frame: a dialog that just closed hands focus back to
      // whatever it had before, which would otherwise win.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNodes[0].requestFocus();
      });
    }
  }

  void _onParentControllerChanged() {
    if (widget.controller.text.isEmpty) {
      _clearAll();
      _focusNodes[0].requestFocus();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onParentControllerChanged);
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Puts [digit] in box [index], or the sentinel when it is empty (index > 0).
  void _writeBox(int index, String digit) {
    _digits[index] = digit;
    final text = digit.isEmpty && index > 0 ? _sentinel : digit;
    final controller = _controllers[index];
    if (controller.text != text) {
      controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  void _clearAll() {
    for (int i = 0; i < 6; i++) {
      _writeBox(i, '');
    }
    if (mounted) setState(() {});
  }

  void _deletePreviousAndFocus(int index) {
    _writeBox(index - 1, '');
    _focusNodes[index - 1].requestFocus();
    setState(() {});
    _emitCode();
  }

  void _onInputChanged(String value, int index) {
    final typed = value
        .replaceAll(_sentinel, '')
        .replaceAll(RegExp(r'[^0-9]'), '');
    final wasEmpty = _digits[index].isEmpty;

    if (typed.isEmpty) {
      // A deletion. On an empty box the sentinel was removed (soft keyboard),
      // so the digit to clear is the previous box's.
      if (wasEmpty && index > 0) {
        _writeBox(index, ''); // restore the sentinel for the next backspace
        _deletePreviousAndFocus(index);
        return;
      }
      _writeBox(index, '');
      setState(() {});
      _emitCode();
      return;
    }

    if (typed.length > 1) {
      // Paste, or a digit typed into an already filled box.
      var written = 0;
      for (int i = 0; i < typed.length && index + i < 6; i++) {
        _writeBox(index + i, typed[i]);
        written++;
      }
      if (index + written < 6) {
        _focusNodes[index + written].requestFocus();
      } else {
        _focusNodes[5].unfocus();
      }
    } else {
      _writeBox(index, typed);
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    setState(() {});
    _emitCode();
  }

  void _emitCode() => widget.onChanged(_digits.join());

  @override
  Widget build(BuildContext context) {
    // CRITICAL: Ambient LTR explicitly enforces standard OTP layout natively
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          final isFocused = _focusNodes[index].hasFocus;
          final isFilled = _digits[index].isNotEmpty;

          return Container(
            width: 53.w,
            height: 56.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: widget.hasError
                    ? AppColors.textError
                    : (isFocused
                          ? AppColors.brandMain
                          : (isFilled
                                ? AppColors.textPrimary
                                : AppColors.borderDeactivated)),
                width: isFocused ? 2.w : 1.w,
              ),
            ),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9$_sentinel]')),
              ],
              readOnly: widget.readOnly,
              showCursor: !widget.readOnly,
              style: TextStyle(
                fontFamily: AppFonts.fontFamilySatoshi,
                fontFamilyFallback: AppFonts.fontFamilyFallback,
                fontSize: AppFonts.size24,
                fontWeight: FontWeight.w600,
                color: widget.hasError
                    ? AppColors.textError
                    : AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
              ),
              // Six pasted digits plus the sentinel.
              maxLength: 7,
              onChanged: (val) => _onInputChanged(val, index),
              onTap: () {
                widget.onTap?.call();
                // Ensure cursor is at the end upon manual tap
                final length = _controllers[index].text.length;
                if (length > 0) {
                  _controllers[index].selection = TextSelection.fromPosition(
                    TextPosition(offset: length),
                  );
                }
              },
            ),
          );
        }),
      ),
    );
  }
}
