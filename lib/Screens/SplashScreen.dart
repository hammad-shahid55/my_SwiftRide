import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swift_ride/Screens/EnableLocationScreen.dart';
import 'package:swift_ride/Screens/OnBoardingScreen.dart';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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

  bool _startAnimations = false;
  bool _showSlideText = false;
  bool _showWavyText = false;
  bool _showLoader = false;
  bool _showSplashContent = true;

  @override
  void initState() {
    super.initState();

    _vanController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _vanAnimation = Tween<Offset>(
      begin: const Offset(-3.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _vanController, curve: Curves.easeOut));

    _textSlideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(-3.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _textSlideController, curve: Curves.easeOut),
    );

    // Delay before animations start (only background shows first)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _startAnimations = true;
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
  }

  /// Internet check + navigation
  Future<void> _checkInternetAndNavigate() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = connectivityResult != ConnectivityResult.none;

    if (hasInternet) {
      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          final isFirstTime = prefs.getBool('isFirstTime') ?? true;

          if (isFirstTime) {
            await prefs.setBool('isFirstTime', false);
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const OnBoardingScreen(),
                ),
              );
            }
          } else {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const EnableLocationScreen(),
                ),
              );
            }
          }
        }
      } on SocketException catch (_) {
        _showNetworkError();
      }
    } else {
      _showNetworkError();
    }
  }

  void _showNetworkError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No internet connection. Please swipe down to refresh.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _showLoader = false;
      });
    }
  }

  @override
  void dispose() {
    _vanController.dispose();
    _textSlideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(123, 61, 244, 1),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _showLoader = true;
          });
          await _checkInternetAndNavigate();
        },
        child:
            _showSplashContent
                ? SingleChildScrollView(
                  // Needed for RefreshIndicator
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child:
                          _startAnimations
                              ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Van animation
                                  SlideTransition(
                                    position: _vanAnimation,
                                    child: Image.asset(
                                      'assets/van_logo.png',
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.70,
                                    ),
                                  ),

                                  // Slide text
                                  if (_showSlideText)
                                    SlideTransition(
                                      position: _textSlideAnimation,
                                      child: Text(
                                        'SwiftRide',
                                        style: TextStyle(
                                          fontSize:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.14,
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

                                  // Wavy text animation
                                  if (_showWavyText)
                                    AnimatedTextKit(
                                      animatedTexts: [
                                        WavyAnimatedText(
                                          'SwiftRide',
                                          textStyle: TextStyle(
                                            fontSize:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.14,
                                            fontWeight: FontWeight.bold,
                                            color: const Color.fromRGBO(
                                              253,
                                              88,
                                              88,
                                              1,
                                            ),
                                          ),
                                          speed: const Duration(
                                            milliseconds: 150,
                                          ),
                                        ),
                                      ],
                                      totalRepeatCount: 1,
                                      onFinished: () {
                                        setState(() {
                                          _showLoader = true;
                                        });

                                        // Wait before checking internet
                                        Future.delayed(
                                          const Duration(seconds: 1),
                                          () {
                                            _checkInternetAndNavigate();
                                          },
                                        );
                                      },
                                    ),

                                  // Loader
                                  if (_showLoader)
                                    LoadingAnimationWidget.threeRotatingDots(
                                      color: const Color.fromRGBO(
                                        253,
                                        88,
                                        88,
                                        1,
                                      ),
                                      size:
                                          MediaQuery.of(context).size.width *
                                          0.12,
                                    ),
                                ],
                              )
                              : const SizedBox.shrink(), // only background first 2 sec
                    ),
                  ),
                )
                : const SizedBox.shrink(),
      ),
    );
  }
}
