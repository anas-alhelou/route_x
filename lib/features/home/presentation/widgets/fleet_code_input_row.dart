// lib/features/home/presentation/widgets/fleet_code_input_row.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routex_mobile/features/home/domain/value_objects/fleet_code.dart';
import 'package:routex_mobile/features/home/presentation/widgets/fleet_code_input_box.dart';

/// Six-box code input for the Enter Fleet Code screen.
///
/// **Fully controlled.** The widget owns its [TextEditingController]s and
/// [FocusNode]s — they are keyboard plumbing — but not the value. [code] is the
/// truth, held by `EnterFleetCodeBloc`, and [onChanged] is the only way the value
/// changes. Nothing outside this class can push a code in imperatively, and the
/// widget never writes to its own controllers in response to a prop it was
/// handed.
///
/// That last rule is the whole point of the file. The previous version took a
/// `codeToFill` prop and reacted to it in `didUpdateWidget` by writing the
/// controllers, calling `requestFocus()` and *emitting `onChanged` again* — a
/// parent → child → parent loop in which the child mutated the parent during the
/// parent's build. Flutter turned that into
/// `setState() or markNeedsBuild() called during build`, and the page's
/// `GlobalKey` on this row's State turned the resulting half-built subtree into
/// a second exception about duplicate keys. Both came from the same three lines;
/// there is no `codeToFill` here and there is no `GlobalKey` in the page.
///
/// When [code] changes from outside — the paste button, "Try again" — the
/// controllers are resynchronized silently. No callback fires, because nothing
/// the user did: re-emitting would feed the value back into the BLoC and start
/// the loop again. Focus is moved in a post-frame callback for the same reason;
/// `requestFocus()` during `didUpdateWidget` marks descendant elements dirty
/// while the tree is still being built.
///
/// The box itself lives in `fleet_code_input_box.dart`: this file holds only the
/// behaviour (controllers, focus chain, paste fan-out) and the box holds only the
/// appearance of a single cell, while the row keeps ownership of the controller
/// and focus node it passes in. Everything the row composes from *outside* — the
/// top bar's Help pill, the error line, the caption row, the footer — has its own
/// file too.
class FleetCodeInputRow extends StatefulWidget {
  const FleetCodeInputRow({
    super.key,
    required this.code,
    required this.onChanged,
    this.hasError = false,
    this.readOnly = false,
    this.onTap,
  });

  /// The current code, normalized via [FleetCode.normalize]. Rendered as one
  /// character per box, left to right.
  final String code;

  /// Reports the whole code after a box changes — from typing, a backspace, or a
  /// paste into a box.
  ///
  /// Only ever called in response to user input. Never as a result of [code]
  /// changing, which is the invariant that keeps this widget out of a build-time
  /// feedback loop.
  final ValueChanged<String> onChanged;

  /// When true, boxes and characters render in the error (red) style.
  ///
  /// Does *not* clear the boxes: the driver needs to see which code was
  /// rejected in order to correct it.
  final bool hasError;

  /// Blocks interaction while submitting.
  final bool readOnly;

  /// Fired when a box is tapped, so the page can dismiss an error the driver has
  /// not started correcting yet.
  final VoidCallback? onTap;

  @override
  State<FleetCodeInputRow> createState() => _FleetCodeInputRowState();
}

/// Private State: no external caller needs to reach in and clear the boxes
/// imperatively, which is why the page holds no `GlobalKey` for this widget.
class _FleetCodeInputRowState extends State<FleetCodeInputRow> {
  /// One controller per box, so each field holds exactly one character and the
  /// caret never has to jump inside a multi-character field.
  final List<TextEditingController> _controllers = List.generate(
    FleetCode.length,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(
    FleetCode.length,
    (_) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < FleetCode.length; i++) {
      // Repaint on focus so the box can thicken its border and recolour the
      // glyph. Only ever reached from a gesture or a post-frame callback, never
      // from build.
      _focusNodes[i].addListener(_onFocusChanged);

      // Backspace on an already-empty box steps back one box instead of doing
      // nothing, which is what makes the row feel like a single field.
      _focusNodes[i].onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace) {
          if (_controllers[i].text.isEmpty && i > 0) {
            _focusNodes[i - 1].requestFocus();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      };
    }

    _writeControllers(FleetCode.normalize(widget.code));
  }

  @override
  void didUpdateWidget(FleetCodeInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    // The echo of our own `onChanged` arrives here as a new `code` that already
    // matches the controllers. Skipping it is what stops an external update
    // (paste, "Try again") and an ordinary keystroke from being handled
    // identically, with the former stealing focus mid-typing.
    // Normalized first so the comparison is against what the boxes would hold,
    // not against whatever casing or padding the caller passed.
    final incoming = FleetCode.normalize(widget.code);
    if (incoming == _joinedCode) return;

    _writeControllers(incoming);
    _focusFirstEmptyBoxAfterFrame();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// The code as the boxes currently hold it.
  String get _joinedCode => _controllers.map((c) => c.text).join();

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  /// Writes [code] into the boxes, one character each.
  ///
  /// Does not notify anyone and does not move focus. `TextEditingController.text`
  /// notifies the field, which is safe during `initState` and
  /// `didUpdateWidget` because those fields have not been built yet this frame;
  /// `requestFocus()` in the same position is not, which is why focus is
  /// deferred.
  void _writeControllers(String code) {
    for (var i = 0; i < FleetCode.length; i++) {
      _controllers[i].text = i < code.length ? code[i] : '';
    }
  }

  /// Moves the caret to the first empty box once this frame has been built.
  ///
  /// Used after an external code change: the driver pasted or pressed "Try
  /// again" and expects to be able to keep typing. When the code is already
  /// full there is nowhere to go, so focus is released instead.
  void _focusFirstEmptyBoxAfterFrame() {
    final emptyIndex = _controllers.indexWhere((c) => c.text.isEmpty);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (emptyIndex == -1) {
        _focusNodes.last.unfocus();
      } else {
        _focusNodes[emptyIndex].requestFocus();
      }
    });
  }

  /// A box changed. Distinguishes three cases the platform reports identically.
  void _onInputChanged(String value, int index) {
    if (value.length > 1) {
      // A paste landed inside a box: fan the characters out from this box.
      // Clamped to the last box so a long paste cannot write past the row, and
      // normalized first so spaces or hyphens in the pasted string do not
      // consume a box.
      final chars = FleetCode.normalize(value).split('');
      for (var i = 0; i < chars.length && index + i < FleetCode.length; i++) {
        _controllers[index + i].text = chars[i];
      }
      _focusAfterFanOut(index + chars.length);
    } else if (value.isNotEmpty) {
      // One typed character: keep it in place and advance.
      _controllers[index].text = value.toUpperCase();
      if (index < FleetCode.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    widget.onChanged(_joinedCode);
  }

  /// Focuses the box the fan-out left off at, or releases focus if the row
  /// filled up.
  void _focusAfterFanOut(int nextIndex) {
    if (nextIndex >= FleetCode.length) {
      _focusNodes.last.unfocus();
      return;
    }
    _focusNodes[nextIndex].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    // An alphanumeric code is always laid out left to right, including on an
    // Arabic device, where a row of boxes that mirrored would make the driver
    // read position 1 as the last character.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          FleetCode.length,
          (index) => FleetCodeInputBox(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            hasError: widget.hasError,
            readOnly: widget.readOnly,
            onChanged: (value) => _onInputChanged(value, index),
            onTap: () => widget.onTap?.call(),
          ),
        ),
      ),
    );
  }
}
