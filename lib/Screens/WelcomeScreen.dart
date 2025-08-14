import 'package:flutter/material.dart';
import 'package:swift_ride/Screens/SignInScreen.dart';
import 'package:swift_ride/Screens/SignUpScreen.dart';
import 'package:swift_ride/Widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.05),

              Image.asset(
                'assets/welcome.png',
                height: screenHeight * 0.35,
                width: screenWidth * 0.9,
                fit: BoxFit.contain,
              ),

              SizedBox(height: screenHeight * 0.05),

              Text(
                "Welcome",
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Urbanist',
                ),
              ),
              SizedBox(height: screenHeight * 0.01),

              Text(
                "Have a better sharing experience",
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: const Color.fromRGBO(160, 160, 160, 1),
                ),
              ),

              const Spacer(),

              CustomButton(
                text: "Create an account",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
              ),

              SizedBox(height: screenHeight * 0.015),

              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.07,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color.fromRGBO(123, 61, 244, 1),
                    side: const BorderSide(
                      color: Color.fromRGBO(123, 61, 244, 1),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  },
                  child: Text(
                    "Log In",
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
