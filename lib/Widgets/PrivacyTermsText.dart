import 'package:flutter/material.dart';
import 'package:swift_ride/Screens/TermsAndConditionsScreen.dart';



class PrivacyTermsText extends StatelessWidget {
  const PrivacyTermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TermsAndConditionsScreen(),
          ),
        );
      },
      child: const Text(
        "Privacy Policy    .    Terms of service",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w300,
          color: Color.fromRGBO(62, 62, 62, 1),
          fontFamily: 'Urbanist',
        ),
      ),
    );
  }
}
