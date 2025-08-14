import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  final double size;
  final Color borderColor;
  final Color activeColor;
  final Color checkColor;

  const CustomCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
    this.size = 20,
    this.borderColor = Colors.black87,
    this.activeColor = Colors.deepPurple,
    this.checkColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(5),
        color: isChecked ? activeColor : Colors.transparent,
      ),
      child: Checkbox(
        value: isChecked,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        activeColor: activeColor,
        checkColor: checkColor,
        side: BorderSide.none, // Removes default border
      ),
    );
  }
}
