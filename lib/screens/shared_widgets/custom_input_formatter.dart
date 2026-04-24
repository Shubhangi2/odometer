import 'package:flutter/services.dart';

class CustomInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow deletion only if we're removing the 6th digit
    if (newValue.text.length < oldValue.text.length) {
      // Only allow deletion if old value had 6 digits (deleting the 6th)
      if (oldValue.text.length <= 3) {
        return oldValue; // allow delete
      }
      return newValue; // block deletion of other digits
    }

    // Allow typing only the 6th digit
    if (newValue.text.length > 3) {
      return newValue; // allow adding the 6th digit
    }

    // Block all other changes
    return oldValue;
  }
}
