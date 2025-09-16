import 'dart:ui';
import 'package:flutter/material.dart';

class LoadingDialog {
  static void show(BuildContext context, {required String message}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Blurred Background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.2), // Dimmed effect
                ),
              ),
            ),
            // Centered Dialog Box
            Center(
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0, // Disable default elevation
                child: Container(
                  width: screenWidth * 0.9, // 90% of screen width
                  height: screenHeight * 0.25, // 25% of screen height
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        screenWidth * 0.25, // Dynamic horizontal padding
                    vertical: screenHeight * 0.05, // Dynamic vertical padding
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 6),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                      SizedBox(height: screenHeight * 0.03), // Responsive gap
                      Text(
                        message,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center, // Center align text
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void dismiss(BuildContext context) {
    Navigator.of(context).pop();
  }
}
