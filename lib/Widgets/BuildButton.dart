import 'package:flutter/material.dart';

class BuildButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const BuildButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF5500FF), // left color
              Color(0xFFFB7B7B), // right color
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: Icon(icon, color: Colors.white, size: 20),
          label: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
