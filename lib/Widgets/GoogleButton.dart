import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: const BorderSide(
            color: Color.fromRGBO(226, 223, 223, 1),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(Colors.grey.withOpacity(0.1)),
        ),
        icon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Image.asset('assets/google_logo.png', width: 24, height: 24),
        ),
        label: const Text(
          "Continue with Google",
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
