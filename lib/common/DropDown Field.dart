import 'package:flutter/material.dart';
import 'dropdown_item.dart';

class CustomDropdownField extends StatelessWidget {
  final List<DropdownItem> items;     // List of ID + Value
  final DropdownItem? value;          // Selected item
  final String hintText;
  final double height;
  final double borderRadius;
  final double fontSize;
  final Function(DropdownItem?) onChanged;

  const CustomDropdownField({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hintText = "Select",
    this.height = 46,
    this.borderRadius = 8,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: const Color(0xFFE2E2E2),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DropdownItem>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF183954),
            size: 18,
          ),

          // Hint
          hint: Text(
            hintText,
            style: TextStyle(
              fontSize: fontSize,
              color: const Color(0x99183954),
              fontWeight: FontWeight.w500,
            ),
          ),

          // Selected text
          style: TextStyle(
            fontSize: fontSize,
            color: const Color(0x99183954),
            fontWeight: FontWeight.w400,
          ),


          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item.name),
            );
          }).toList(),

          onChanged: onChanged,
        ),
      ),
    );
  }
}
