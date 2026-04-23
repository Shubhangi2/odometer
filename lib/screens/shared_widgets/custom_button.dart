import 'package:speedometer/core/app_colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double? width;
  final double? padding;
  final double? borderRadius;
  final Color? borderColor;
  final double? height;
  final Color? color;
  final VoidCallback onPressed;
  final double? fontSize;
  final Color? textColor;
  final Icon? prefixIcon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.borderColor,
    this.fontSize,
    this.width,
    this.height,
    this.padding,
    this.color,
    this.borderRadius,
    this.prefixIcon,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          width: borderColor == null ? 0 : 1,
          color: borderColor ?? Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? 18),
        color: color ?? AppColors.primary,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? 24)),
          backgroundColor: color ?? Colors.transparent,
          padding: padding == null ? null : EdgeInsets.symmetric(horizontal: padding!),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prefixIcon != null)
              Padding(padding: const EdgeInsets.only(right: 4.0), child: prefixIcon!),
            Text(
              text,
              style: TextStyle(fontSize: fontSize ?? 16, color: textColor ?? Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
