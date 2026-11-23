import 'package:flutter/services.dart';

/// Prevents the user from entering additional characters (like digits) after ".com".
class EmailSuffixFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.toLowerCase().contains('.com')) {
      final index = newValue.text.toLowerCase().indexOf('.com');
      // If the new text has anything after '.com', prevent it.
      if (newValue.text.length > index + 4) {
        // If it was pasted, truncate it
        if (!oldValue.text.toLowerCase().contains('.com')) {
          final fixed = newValue.text.substring(0, index + 4);
          return TextEditingValue(
            text: fixed,
            selection: TextSelection.collapsed(offset: fixed.length),
          );
        }
        // Otherwise, reject the keystroke after .com
        return oldValue;
      }
    }
    return newValue;
  }
}
