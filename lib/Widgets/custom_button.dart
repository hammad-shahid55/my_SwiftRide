import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SizedBox(
      width: double.infinity,
      height: size.height * 0.065,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient:
              isSecondary
                  ? null
                  : const LinearGradient(
                    colors: [
                      Color(0xFF5500FF), // left color
                      Color(0xFFFB7B7B), // right color
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
          color: isSecondary ? Colors.grey.shade300 : null,
          borderRadius: BorderRadius.circular(size.width * 0.02),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(size.width * 0.02),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.w600,
              color: textColor ?? (isSecondary ? Colors.black87 : Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
