import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  final String text;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const MainButton({
    super.key,
    required this.text,
    this.gradient,
    this.backgroundColor,
    this.textColor = Colors.white,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: textColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
