import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CustomBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerSize = screenWidth * 0.06; // Responsive container size
    double arrowWidth = containerSize * 0.25; // Keep width proportional
    double arrowHeight = containerSize * 0.5; // Keep height proportional

    return GestureDetector(
      onTap: onPressed ?? () => Navigator.pop(context),
      child: Container(
        color: Colors.grey[50],
        width: containerSize,
        height: containerSize,
        alignment: Alignment.center,
        child: CustomPaint(
          size: Size(arrowWidth, arrowHeight),
          painter: _BackArrowPainter(),
        ),
      ),
    );
  }
}

class _BackArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = const Color.fromRGBO(12, 20, 25, 1)
          ..strokeWidth =
              size.width *
              0.25 // Keeps stroke width proportional
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final Path path =
        Path()
          ..moveTo(size.width, 0)
          ..lineTo(0, size.height / 2)
          ..lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
