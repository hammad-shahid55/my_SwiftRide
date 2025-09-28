import 'package:flutter/material.dart';

class AppTheme {
  // Gradient you can reuse everywhere
  static const LinearGradient mainGradient = LinearGradient(
    colors: [Color(0xFF7B3DF4), Color(0xFFFD5858)], // Purple → Red
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Solid fallback background color
  static const Color backgroundColor = Color(0xFFF9F9F9);

  // Button color
  static const Color buttonColor = Color(0xFF7B3DF4);

  // Text color
  static const Color textColor = Colors.white;
}


  //  backgroundColor: Colors.transparent,
  // flexibleSpace: Container(
  //   decoration: const BoxDecoration(
  //     gradient: AppTheme.mainGradient,
  //   ),
  // ),