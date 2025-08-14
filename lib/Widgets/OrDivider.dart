import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  final Color dividerColor;
  final double thickness;
  final double horizontalPadding;
  final String text;
  final TextStyle? textStyle;

  const OrDivider({
    super.key,
    this.dividerColor = const Color.fromRGBO(185, 185, 185, 1),
    this.thickness = 1,
    this.horizontalPadding = 10,
    this.text = 'or',
    this.textStyle = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 15,
      fontFamily: 'Urbanist',
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: thickness,
            color: dividerColor,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Text(
            text,
            style: textStyle,
          ),
        ),
        Expanded(
          child: Divider(
            thickness: thickness,
            color: dividerColor,
          ),
        ),
      ],
    );
  }
}
