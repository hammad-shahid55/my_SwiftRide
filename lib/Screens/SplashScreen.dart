import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swift_ride/Screens/EnableLocationScreen.dart';
import 'package:swift_ride/Screens/OnBoardingScreen.dart';
import 'package:swift_ride/Screens/HomeScreen.dart';
import 'package:geolocator/geolocator.dart';
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
  bool _showTagline = false;

  @override
  void initState() {
    super.initState();

    _vanController = AnimationController(
      duration: const Duration(milliseconds: 1300),
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

    // Start animations after delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _startAnimations = true);
      _vanController.forward().whenComplete(() {
        setState(() => _showSlideText = true);
        _textSlideController.forward().whenComplete(() {
          setState(() {
            _showWavyText = true;
            _showSlideText = false;
          });
        });
      });
    });
  }

  /// Check internet + location + first time + navigate
  Future<void> _checkInternetAndNavigate() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = connectivityResult != ConnectivityResult.none;
    if (!hasInternet) {
      _showNetworkError();
      return;
    }

    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        _showNetworkError();
        return;
      }

      // First time user?
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;
      if (isFirstTime) {
        await prefs.setBool('isFirstTime', false);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
          );
        }
        return;
      }

      // Location check
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (serviceEnabled &&
          (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse)) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
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
    } on SocketException catch (_) {
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
      setState(() => _showLoader = false);
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _showLoader = true);
          await _checkInternetAndNavigate();
        },
        child:
            _showSplashContent
                ? Stack(
                  children: [
                    // Gradient background
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF7B3DF4), Color(0xFFFD5858)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),

                    // Decorative circles
                    Positioned(
                      top: -80,
                      right: -80,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -60,
                      left: -60,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Watermark image
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.05,
                        child: Image.asset(
                          'assets/van_logo.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),

                    // Main splash content
                    SingleChildScrollView(
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
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.70,
                                        ),
                                      ),

                                      const SizedBox(height: 20),

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
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 8,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  offset: const Offset(2, 2),
                                                ),
                                              ],
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
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: 8,
                                                    color: Colors.black
                                                        .withOpacity(0.4),
                                                    offset: const Offset(2, 2),
                                                  ),
                                                ],
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
                                              _showTagline = true;
                                            });
                                            Future.delayed(
                                              const Duration(seconds: 1),
                                              () => _checkInternetAndNavigate(),
                                            );
                                          },
                                        ),

                                      const SizedBox(height: 15),

                                      // Tagline
                                      if (_showTagline)
                                        AnimatedOpacity(
                                          opacity: 1.0,
                                          duration: const Duration(
                                            milliseconds: 800,
                                          ),
                                          child: Text(
                                            "Ride Smart, Ride Swift",
                                            style: TextStyle(
                                              fontSize:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.05,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),

                                      const SizedBox(height: 20),

                                      // Loader
                                      if (_showLoader)
                                        LoadingAnimationWidget.staggeredDotsWave(
                                          color: Colors.white,
                                          size:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.12,
                                        ),
                                    ],
                                  )
                                  : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                )
                : const SizedBox.shrink(),
      ),
    );
  }
}
