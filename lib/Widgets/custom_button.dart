import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final bool isSecondary;
  final Color? textColor; 

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.isSecondary = false,
    this.textColor, 
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SizedBox(
      width: double.infinity,
      height: size.height * 0.065,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ??
              (isSecondary
                  ? Colors.grey.shade300
                  : const Color.fromRGBO(123, 61, 244, 1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.width * 0.02),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.w500,
            color: textColor ??
                (isSecondary ? Colors.black87 : Colors.white), 
          ),
        ),
      ),
    );
  }
}
