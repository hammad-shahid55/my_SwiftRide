import 'package:flutter/material.dart';

class HomeIndicator extends StatelessWidget {
  const HomeIndicator({super.key}); // Added const constructor

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double indicatorWidth = screenWidth * 0.35;
    final double indicatorHeight = screenWidth * 0.01;
    final double borderRadius = indicatorHeight * 2;

    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.03),
      child: Center(
        child: Container(
          width: indicatorWidth,
          height: indicatorHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
