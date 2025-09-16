import 'package:flutter/material.dart';
import 'package:swift_ride/Widgets/CustomAppBar.dart';

import 'package:swift_ride/Widgets/Homeindicator.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 246, 1),
      appBar: CustomAppBar(title: "Terms & Conditions"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.01),
                    _buildSectionMainTitle(
                      "Oulu Tech Terms & Conditions",
                      screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    _buildSectionBody(
                      "Welcome to Oulu tech! Before you dive into the exciting world of social connections, courses, and events, please take a moment to review our brief terms and conditions.",
                      screenWidth,
                    ),
                    _buildSectionTitle("1. Acceptance of Terms:", screenWidth),
                    _buildSectionBody(
                      "By using the Oulu tech app, you agree to abide by these terms and conditions.",
                      screenWidth,
                    ),
                    _buildSectionTitle(
                      "2. User Responsibilities:",
                      screenWidth,
                    ),
                    _buildSectionBody(
                      "You are responsible for the content you post. Respect the community guidelines and ensure your contributions are lawful and respectful.",
                      screenWidth,
                    ),
                    _buildSectionTitle("3. Privacy:", screenWidth),
                    _buildPrivacySection(screenWidth),
                    _buildSectionTitle(
                      "4. Intellectual Property:",
                      screenWidth,
                    ),
                    _buildSectionBody(
                      "Respect intellectual property rights. Don’t infringe on copyrights or trademarks when posting content.",
                      screenWidth,
                    ),
                    _buildSectionTitle(
                      "5. Prohibited Activities:",
                      screenWidth,
                    ),
                    _buildSectionBody(
                      "Engaging in harmful activities, spam, or any form of abuse is not allowed. Be a positive force in our community.",
                      screenWidth,
                    ),
                    _buildSectionTitle("6. Termination:", screenWidth),
                    _buildSectionBody(
                      "We reserve the right to terminate accounts violating our terms without notice.",
                      screenWidth,
                    ),
                    _buildSectionTitle("7. Updates:", screenWidth),
                    _buildSectionBody(
                      "Terms may be updated; it’s your responsibility to stay informed.",
                      screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildSectionBody(
                      "Thanks for being part of Marché – let’s create an amazing social experience together!",
                      screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
          const HomeIndicator(),
        ],
      ),
    );
  }

  Widget _buildSectionMainTitle(String title, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: "Urbanist",
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.w500,
          color: const Color.fromRGBO(62, 62, 62, 1),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: "Urbanist",
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.w700,
          color: const Color.fromRGBO(62, 62, 62, 1),
        ),
      ),
    );
  }

  Widget _buildSectionBody(String text, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "Urbanist",
          fontSize: screenWidth * 0.035,
          fontWeight: FontWeight.w500,
          color: const Color.fromRGBO(185, 185, 185, 1),
        ),
      ),
    );
  }

  Widget _buildPrivacySection(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: "Urbanist",
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w500,
            color: const Color.fromRGBO(185, 185, 185, 1),
          ),
          children: [
            const TextSpan(text: "We value your privacy. Check out our "),
            TextSpan(
              text: "Privacy Policy",
              style: const TextStyle(color: Color.fromRGBO(255, 203, 0, 1)),
            ),
            const TextSpan(
              text:
                  " to understand how we collect, use, and protect your personal information.",
            ),
          ],
        ),
      ),
    );
  }
}
