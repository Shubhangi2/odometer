import 'package:flutter/services.dart';
import 'package:speedometer/core/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final Color? hintTextColor;
  final Icon? prefixIcon;
  final TextInputType textInputType;
  final Color? borderColor;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool? obscureText;
  final Function(String value) onValidate;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.hintTextColor,
    this.prefixIcon,
    this.maxLines,
    required this.inputFormatters,
    this.obscureText,
    required this.onValidate,
    required this.textInputType,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: inputFormatters,
      controller: controller,
      keyboardType: textInputType,
      obscureText: obscureText ?? false,
      maxLines: obscureText ?? false ? 1 : maxLines,
      decoration: InputDecoration(
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.error)) {
            return TextStyle(color: Colors.red[900]);
          }
          return const TextStyle(color: Colors.red);
        }),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        label: Text(label),
        alignLabelWithHint: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor ?? Colors.red),
        ),

        hint: Text(hintText, style: TextStyle(color: hintTextColor ?? Colors.red, fontSize: 16)),
        prefixIcon: prefixIcon,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => onValidate(value!),
    );
  }
}
