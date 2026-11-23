import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'company_code_box.dart';

/// 6-character code input row with automatic focus navigation and clipboard fan-out.
class CompanyCodeInputRow extends StatefulWidget {
  const CompanyCodeInputRow({
    super.key,
    required this.code,
    required this.onChanged,
    this.hasError = false,
    this.readOnly = false,
    this.onTap,
  });

  final String code;
  final ValueChanged<String> onChanged;
  final bool hasError;
  final bool readOnly;
  final VoidCallback? onTap;

  static const int codeLength = 6;

  @override
  State<CompanyCodeInputRow> createState() => _CompanyCodeInputRowState();
}

class _CompanyCodeInputRowState extends State<CompanyCodeInputRow> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      CompanyCodeInputRow.codeLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      CompanyCodeInputRow.codeLength,
      (_) => FocusNode(),
    );

    for (var i = 0; i < CompanyCodeInputRow.codeLength; i++) {
      _focusNodes[i].addListener(_onFocusChange);
    }

    _syncFromCode(widget.code);
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(CompanyCodeInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.code != oldWidget.code) {
      _syncFromCode(widget.code);
    }
  }

  void _syncFromCode(String code) {
    for (var i = 0; i < CompanyCodeInputRow.codeLength; i++) {
      final char = i < code.length ? code[i] : '';
      if (_controllers[i].text != char) {
        _controllers[i].text = char;
      }
    }
  }

  String _assembleCode() {
    final buffer = StringBuffer();
    for (final c in _controllers) {
      buffer.write(c.text);
    }
    return buffer.toString();
  }

  void _handleBoxChanged(int index, String value) {
    if (value.length > 1) {
      // User pasted or typed multiple characters into this box
      final clean = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
      var writeIndex = index;
      for (var i = 0; i < clean.length && writeIndex < CompanyCodeInputRow.codeLength; i++) {
        _controllers[writeIndex].text = clean[i];
        writeIndex++;
      }
      final newCode = _assembleCode();
      widget.onChanged(newCode);

      if (writeIndex < CompanyCodeInputRow.codeLength) {
        _focusNodes[writeIndex].requestFocus();
      } else {
        _focusNodes.last.unfocus();
      }
      return;
    }

    if (value.isNotEmpty) {
      _controllers[index].text = value.toUpperCase();
      final newCode = _assembleCode();
      widget.onChanged(newCode);

      if (index + 1 < CompanyCodeInputRow.codeLength) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      // Deleted character
      final newCode = _assembleCode();
      widget.onChanged(newCode);
    }
  }

  @override
  void dispose() {
    for (var i = 0; i < CompanyCodeInputRow.codeLength; i++) {
      _focusNodes[i].removeListener(_onFocusChange);
      _focusNodes[i].dispose();
      _controllers[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.backspace): () {
          for (var i = 0; i < CompanyCodeInputRow.codeLength; i++) {
            if (_focusNodes[i].hasFocus) {
              if (_controllers[i].text.isEmpty && i > 0) {
                _controllers[i - 1].text = '';
                _focusNodes[i - 1].requestFocus();
                widget.onChanged(_assembleCode());
              }
              break;
            }
          }
        },
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(CompanyCodeInputRow.codeLength, (index) {
          return CompanyCodeBox(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            hasError: widget.hasError,
            readOnly: widget.readOnly,
            onChanged: (val) => _handleBoxChanged(index, val),
            onTap: () {
              widget.onTap?.call();
            },
          );
        }),
      ),
    );
  }
}
