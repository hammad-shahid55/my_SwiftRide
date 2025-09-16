import 'package:flutter/material.dart';
import 'package:swift_ride/Screens/EnableLocationScreen.dart';
import 'package:swift_ride/Widgets/Homeindicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/onboarding_1.png",
      "title": "Anywhere you are",
      "subtitle":
          "Your smart ride-sharing app designed for students and professionals.",
    },
    {
      "image": "assets/onboarding_4.png",
      "title": "Fixed Routes",
      "subtitle": "Enjoy seamless experience with our fixed route system.",
    },
    {
      "image": "assets/onboarding_3.png",
      "title": "Track in Real Time",
      "subtitle": "Know exactly where your ride is with live tracking.",
    },
  ];

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EnableLocationScreen()),
    );
  }

  Widget _buildArrowProgress() {
    double progress = (_currentPage + 1) / _onboardingData.length;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: const Color.fromRGBO(199, 176, 247, 1),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color.fromRGBO(123, 61, 244, 1),
            ),
          ),
        ),
        _currentPage == _onboardingData.length - 1
            ? TextButton(
              onPressed: _goToHome,
              child: const Text(
                "Go",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            )
            : IconButton(
              icon: const Icon(
                Icons.arrow_forward,
                size: 32,
                color: Color.fromRGBO(123, 61, 244, 1),
              ),
              onPressed: () {
                if (_currentPage < _onboardingData.length - 1) {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.ease,
                  );
                } else {
                  _goToHome();
                }
              },
            ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _controller,
                    itemCount: _onboardingData.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final item = _onboardingData[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.06,
                          vertical: size.height * 0.02,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: size.height * 0.08),
                            Image.asset(
                              item['image'] ?? '',
                              height: size.height * 0.3,
                              width: size.width * 0.8,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: size.height * 0.05),
                            Text(
                              item['title'] ?? '',
                              style: TextStyle(
                                fontSize: size.width * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: size.height * 0.02),
                            Text(
                              item['subtitle'] ?? '',
                              style: TextStyle(fontSize: size.width * 0.04),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),
                            _buildArrowProgress(),
                            SizedBox(height: size.height * 0.04),
                          ],
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child:
                        _currentPage < _onboardingData.length - 1
                            ? TextButton(
                              onPressed: _goToHome,
                              child: const Text(
                                "Skip",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            HomeIndicator(),
          ],
        ),
      ),
    );
  }
}
