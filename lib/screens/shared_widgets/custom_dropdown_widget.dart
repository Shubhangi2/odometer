import 'package:speedometer/core/app_colors.dart';
import 'package:flutter/material.dart';

class CustomDropdownWidget<T> extends StatelessWidget {
  final List<T> dropdownList;
  final String hintText;
  final IconData icon;
  final T? initialSelection;
  final Function(T value) onSelected;
  final String Function(T item) itemToString;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const CustomDropdownWidget({
    super.key,
    required this.dropdownList,
    required this.hintText,
    required this.icon,
    this.initialSelection,
    required this.onSelected,
    required this.itemToString,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 48,
          child: DropdownMenu<T>(
            menuStyle: MenuStyle(
              maximumSize: WidgetStateProperty.all(Size(width ?? constraints.maxWidth, 500)),
              backgroundColor: WidgetStateProperty.all(AppColors.secondary),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  side: const BorderSide(color: AppColors.secondaryBorder, width: 1.0),
                ),
              ),
            ),
            width: width ?? constraints.maxWidth,
            textStyle: const TextStyle(color: Colors.white, fontSize: 16),

            initialSelection: initialSelection,
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: const TextStyle(color: AppColors.hintGray),
              filled: true,
              fillColor: AppColors.secondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.0),
                borderSide: const BorderSide(color: AppColors.secondaryBorder, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.0),
                borderSide: const BorderSide(color: AppColors.secondaryBorder, width: 1.0),
              ),

              contentPadding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            hintText: hintText,
            onSelected: (T? value) {
              if (value != null) {
                onSelected(value);
              }
            },
            dropdownMenuEntries: dropdownList.map<DropdownMenuEntry<T>>((T item) {
              return DropdownMenuEntry<T>(
                value: item,
                label: itemToString(item),
                labelWidget: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  child: Text(
                    itemToString(item),
                    softWrap: true,
                    maxLines: null, // Allows unlimited lines
                    overflow: TextOverflow.visible,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
