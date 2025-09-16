import 'dart:async';
import 'package:flutter/material.dart';
import 'package:swift_ride/Screens/OnBoardingScreen.dart';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _vanController;
  late Animation<Offset> _vanAnimation;

  late AnimationController _textSlideController;
  late Animation<Offset> _textSlideAnimation;

  bool _showSlideText = false;
  bool _showWavyText = false;
  bool _showLoader = false;
  bool _showSplashContent = false;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      setState(() {
        _showSplashContent = true;
      });

      _vanController.forward().whenComplete(() {
        setState(() {
          _showSlideText = true;
        });
        _textSlideController.forward().whenComplete(() {
          setState(() {
            _showWavyText = true;
            _showSlideText = false;
          });
        });
      });
    });

    Timer(const Duration(seconds: 13), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnBoardingScreen()),
      );
    });

    _vanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _vanAnimation = Tween<Offset>(
      begin: const Offset(-3.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _vanController, curve: Curves.easeOut));

    _textSlideController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(-3.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _textSlideController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _vanController.dispose();
    _textSlideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          return Scaffold(
            backgroundColor: const Color.fromRGBO(123, 61, 244, 1),
            body:
                _showSplashContent
                    ? Stack(
                      children: [
                        // Blobs
                        Positioned(
                          top: -screenHeight * 0.33,
                          left: -screenWidth * 0.73,
                          child: Image.asset(
                            'assets/blob1.png',
                            width: screenWidth * 1.75,
                          ),
                        ),
                        Positioned(
                          top: -screenHeight * 0.25,
                          right: -screenWidth * 0.43,
                          child: Image.asset(
                            'assets/blob2.png',
                            width: screenWidth * 1.25,
                          ),
                        ),
                        Positioned(
                          bottom: -screenHeight * 0.22,
                          right: -screenWidth * 0.44,
                          child: Image.asset(
                            'assets/blob3.png',
                            width: screenWidth * 1.25,
                          ),
                        ),
                        Positioned(
                          bottom: -screenHeight * 0.18,
                          left: -screenWidth * 0.45,
                          child: Image.asset(
                            'assets/blob4.png',
                            width: screenWidth * 1.30,
                          ),
                        ),
                        Positioned(
                          top: screenHeight * 0.575,
                          left: -screenWidth * 0.255,
                          child: Image.asset(
                            'assets/blob5.png',
                            width: screenWidth * 1.3,
                          ),
                        ),
                        Positioned(
                          top: screenHeight * 0.44,
                          right: -screenWidth * 0.57,
                          child: Image.asset(
                            'assets/blob6.png',
                            width: screenWidth * 1.25,
                          ),
                        ),
                        Positioned(
                          bottom: screenHeight * 0.425,
                          right: screenWidth * 0.16,
                          child: Image.asset(
                            'assets/blob7.png',
                            width: screenWidth * 1.35,
                          ),
                        ),
                        Positioned(
                          bottom: screenHeight * 0.55,
                          left: -screenWidth * 0.20,
                          child: Image.asset(
                            'assets/blob8.png',
                            width: screenWidth * 1.35,
                          ),
                        ),

                        // Centered animated content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SlideTransition(
                                position: _vanAnimation,
                                child: Image.asset(
                                  'assets/van_logo.png',
                                  width: screenWidth * 0.70,
                                ),
                              ),
                              if (_showSlideText)
                                SlideTransition(
                                  position: _textSlideAnimation,
                                  child: Text(
                                    'SwiftRide',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromRGBO(
                                        253,
                                        88,
                                        88,
                                        1,
                                      ),
                                    ),
                                  ),
                                ),
                              if (_showWavyText)
                                AnimatedTextKit(
                                  animatedTexts: [
                                    WavyAnimatedText(
                                      'SwiftRide',
                                      textStyle: TextStyle(
                                        fontSize: screenWidth * 0.14,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromRGBO(
                                          253,
                                          88,
                                          88,
                                          1,
                                        ),
                                      ),
                                      speed: const Duration(milliseconds: 300),
                                    ),
                                  ],
                                  totalRepeatCount: 1,
                                  onFinished: () {
                                    setState(() {
                                      _showLoader = true;
                                    });
                                  },
                                ),
                              if (_showLoader)
                                LoadingAnimationWidget.threeRotatingDots(
                                  color: const Color.fromRGBO(253, 88, 88, 1),
                                  size: screenWidth * 0.12,
                                ),
                            ],
                          ),
                        ),
                      ],
                    )
                    : const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
