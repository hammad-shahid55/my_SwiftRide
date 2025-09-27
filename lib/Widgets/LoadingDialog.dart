import 'dart:ui';
import 'package:flutter/material.dart';

class LoadingDialog {
  static void show(BuildContext context, {required String message}) {
    final double screenWidth = MediaQuery.of(context).size.width;

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
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),
            // Centered Dialog Box
            Center(
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Container(
                  width: screenWidth * 0.9, // Max width
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // fit content
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          message,
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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
