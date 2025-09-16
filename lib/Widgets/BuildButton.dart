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
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        icon: Icon(icon, color: Colors.black, size: 20),
        label: Text(
          text,
          style: const TextStyle(
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
