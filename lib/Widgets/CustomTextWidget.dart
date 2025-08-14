import 'package:flutter/material.dart';

class CustomTextWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final double titleSize;
  final double subtitleSize;
  final FontWeight titleWeight;
  final FontWeight subtitleWeight;
  final Color titleColor;
  final Color subtitleColor;
  final TextAlign textAlign;
  final CrossAxisAlignment alignment;
  final double spacing;
  final String fontFamily; // ✅ Required to fix the error

  const CustomTextWidget({
    super.key,
    required this.title,
    this.subtitle = "",
    this.titleSize = 24,
    this.subtitleSize = 16,
    this.titleWeight = FontWeight.w600,
    this.subtitleWeight = FontWeight.w300,
    this.titleColor = const Color.fromRGBO(0, 0, 0, 1),
    this.subtitleColor = const Color.fromRGBO(62, 62, 62, 1),
    this.textAlign = TextAlign.start,
    this.alignment = CrossAxisAlignment.start,
    this.spacing = 8.0,
    this.fontFamily = 'Poppins',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: titleWeight,
            fontFamily: fontFamily,
            color: titleColor,
          ),
          textAlign: textAlign,
        ),
        if (subtitle.isNotEmpty && spacing > 0) SizedBox(height: spacing),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: TextStyle(
              fontSize: subtitleSize,
              fontWeight: subtitleWeight,
              fontFamily: fontFamily,
              color: subtitleColor,
            ),
            textAlign: textAlign,
          ),
      ],
    );
  }
}
