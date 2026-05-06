import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputFormatter extends TextInputFormatter {
  CustomInputFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final oldText = oldValue.text;
    final newText = newValue.text;

    if (newText.length < oldText.length) {
      if (newText.length >= 4) {
        return newValue;
      }
      return oldValue;
    }
    if (newText.length > oldText.length) {
      if (newText.length <= 6) {
        return newValue;
      }
      return oldValue;
    }
    return oldValue;
  }
}
