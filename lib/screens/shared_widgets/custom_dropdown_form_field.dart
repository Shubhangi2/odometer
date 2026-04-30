import 'package:odometer/core/app_colors.dart';
import 'package:flutter/material.dart';

class CustomDropdownFormField<T> extends StatefulWidget {
  final List<T> dropdownList;
  final String hintText;
  final T? initialSelection;
  final Function(T value) onSelected;
  final String Function(T item) itemToString;
  final double width;

  const CustomDropdownFormField({
    super.key,
    required this.dropdownList,
    required this.hintText,
    this.initialSelection,
    required this.onSelected,
    required this.itemToString,
    required this.width,
  });

  @override
  State<CustomDropdownFormField<T>> createState() => _CustomDropdownFormFieldState<T>();
}

class _CustomDropdownFormFieldState<T> extends State<CustomDropdownFormField<T>> {
  T? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialSelection;
  }

  @override
  void didUpdateWidget(CustomDropdownFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelection != oldWidget.initialSelection) {
      selectedValue = widget.initialSelection;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 42,

      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
          ),
        ),
        child: DropdownButton<T>(
          menuWidth: 200,
          value: selectedValue,
          icon: const Icon(Icons.arrow_drop_down),
          elevation: 16,
          isExpanded: true,
          style: const TextStyle(color: Colors.black),
          underline: Container(height: 1, color: Colors.white),
          hint: Text(widget.hintText),
          onChanged: (T? value) {
            if (value != null) {
              setState(() {
                selectedValue = value;
              });
              widget.onSelected(value);
            }
          },
          items: widget.dropdownList.map<DropdownMenuItem<T>>((T value) {
            return DropdownMenuItem<T>(
              value: value,
              child: Text(widget.itemToString(value), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        ),
      ),
    );
  }
}
