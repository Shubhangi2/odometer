import 'package:speedometer/core/app_colors.dart';
import 'package:flutter/material.dart';

class CustomDropdownWithWrap<T> extends StatefulWidget {
  final List<T> dropdownList;
  final String hintText;
  final IconData icon;
  final T? initialSelection;
  final Function(T value) onSelected;
  final String Function(T item) itemToString;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const CustomDropdownWithWrap({
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
  State<CustomDropdownWithWrap<T>> createState() => _CustomDropdownWithWrapState<T>();
}

class _CustomDropdownWithWrapState<T> extends State<CustomDropdownWithWrap<T>> {
  T? selectedValue;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialSelection;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggleDropdown() {
    if (isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => isOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeDropdown,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0.0, size.height + 5.0),
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red, width: 1.0),
                    ),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: widget.dropdownList.map((item) {
                        return InkWell(
                          onTap: () {
                            setState(() => selectedValue = item);
                            widget.onSelected(item);
                            _closeDropdown();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedValue == item
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.white,
                              border: Border(
                                bottom: BorderSide(color: Colors.red.withOpacity(0.3), width: 0.5),
                              ),
                            ),
                            child: Text(
                              widget.itemToString(item),
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                              softWrap: true,
                              maxLines: null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleDropdown,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: isOpen ? Colors.red : Colors.blue, width: 1.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedValue != null ? widget.itemToString(selectedValue as T) : widget.hintText,
                  style: TextStyle(
                    color: selectedValue != null ? Colors.red : Colors.red,
                    fontSize: 14,
                  ),
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}
