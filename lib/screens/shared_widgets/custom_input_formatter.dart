import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputFormatter extends TextInputFormatter {
  final int totalLength;
  final int editableFromIndex;

  CustomInputFormatter({required this.totalLength, required this.editableFromIndex});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final oldText = oldValue.text;
    final newText = newValue.text;

    if (newText.length < oldText.length) {
      final deletedIndex = newText.length;
      if (deletedIndex < editableFromIndex) {
        return oldValue;
      }
      return newValue;
    }
    if (newText.length > oldText.length) {
      if (newText.length > totalLength) {
        return oldValue;
      }

      final insertedIndex = newText.length - 1;
      if (insertedIndex < editableFromIndex) {
        return oldValue;
      }
      return newValue;
    }

    return oldValue;
  }
}
