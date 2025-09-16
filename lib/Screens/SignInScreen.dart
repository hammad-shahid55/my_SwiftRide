import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Screens/ForgotPasswordScreen.dart';
import 'package:swift_ride/Screens/SignUpScreen.dart';
import 'package:swift_ride/Screens/PhoneNumberSignUpScreen.dart';
import 'package:swift_ride/Screens/UserProfileScreen.dart';
import 'package:swift_ride/Widgets/BuildButton.dart';
import 'package:swift_ride/Widgets/CustomCheckbox.dart';
import 'package:swift_ride/Widgets/CustomTextField.dart';
import 'package:swift_ride/Widgets/CustomTextWidget.dart';
import 'package:swift_ride/Widgets/GoogleButton.dart';
import 'package:swift_ride/Widgets/Homeindicator.dart';
import 'package:swift_ride/Widgets/LoadingDialog.dart';
import 'package:swift_ride/Widgets/MainButton.dart';
import 'package:swift_ride/Widgets/OrDivider.dart';
import 'package:swift_ride/Widgets/PrivacyTermsText.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isChecked = false;

  void signInUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    // ✅ Check network before sign in
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('No Internet'),
              content: Row(
                children: const [
                  Icon(CupertinoIcons.wifi_exclamationmark, size: 28),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Network not available. Please connect to the internet.',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    LoadingDialog.show(context, message: 'Signing in...');

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        LoadingDialog.dismiss(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserProfileScreen()),
        );
      } else {
        LoadingDialog.dismiss(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please check credentials.'),
          ),
        );
      }
    } on AuthException catch (error) {
      LoadingDialog.dismiss(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (e) {
      LoadingDialog.dismiss(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Try again!')),
      );
    }
  }

  void signInWithGoogle() async {
    try {
      LoadingDialog.show(context, message: 'Signing in with Google...');
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback/',
      );
      LoadingDialog.dismiss(context);

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserProfileScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in failed. Try again.')),
        );
      }
    } catch (error) {
      LoadingDialog.dismiss(context);
      debugPrint('Google Sign-In Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign-In failed. Try again.')),
      );
    }
  }

  void continueWithPhone() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContinueWithPhoneNumber()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 246, 246, 1),
      body: SizedBox(
        height: screenHeight,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.05,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: screenHeight * 0.03),
                      CustomTextWidget(
                        title: "👋 Welcome Back!",
                        spacing: 8,
                        subtitle: "Let’s dive into your account",
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      CustomTextField(
                        label: 'Email',
                        hintText: '',
                        isEmail: true,
                        suffixIcon: Icons.email_outlined,
                        controller: emailController,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      CustomTextField(
                        label: 'Password',
                        hintText: 'Password',
                        isPassword: true,
                        controller: passwordController,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CustomCheckbox(
                                isChecked: isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    isChecked = value ?? false;
                                  });
                                },
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              const Text(
                                'Remember me',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  fontFamily: 'Urbanist',
                                  color: Color.fromRGBO(62, 62, 62, 1),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forget Password?',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                fontFamily: 'Urbanist',
                                color: Color.fromRGBO(62, 62, 62, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.025),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ),
                            );
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: 'Don’t have an account? ',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(62, 62, 62, 1),
                                fontSize: 15,
                                fontFamily: 'Urbanist',
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign up',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(123, 61, 244, 1),
                                    fontSize: 15,
                                    fontFamily: 'Urbanist',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      OrDivider(),
                      SizedBox(height: screenHeight * 0.04),
                      GoogleButton(onPressed: signInWithGoogle),
                      SizedBox(height: screenHeight * 0.02),
                      BuildButton(
                        icon: Icons.phone,
                        text: "Continue with Phone",
                        onPressed: continueWithPhone,
                      ),
                      SizedBox(height: screenHeight * 0.06),
                      MainButton(
                        text: 'Sign In',
                        backgroundColor: const Color.fromRGBO(123, 61, 244, 1),
                        onPressed: signInUser,
                        
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      const Center(child: PrivacyTermsText()),
                    ],
                  ),
                ),
              ),
            ),
            const HomeIndicator(),
          ],
        ),
      ),
    );
  }
}
