import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white, // Changed to white background
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.black, // Adjusted text color for contrast
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          icon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Image.asset(
              'assets/google_logo.png',
              width: 24,
              height: 24,
              // Removed color overlay to use the original asset colors
            ),
          ),
          label: const Text(
            "Continue with Google",
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black, // Adjusted text color for contrast
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
