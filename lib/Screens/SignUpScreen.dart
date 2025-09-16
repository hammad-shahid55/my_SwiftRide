import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Screens/PhoneNumberSignUpScreen.dart';
import 'package:swift_ride/Screens/SignInScreen.dart';
import 'package:swift_ride/Screens/TermsAndConditionsScreen.dart';
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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isChecked = false;

  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final bool exists = await supabase.rpc(
        'check_user_email_exists',
        params: {'email_input': email},
      );
      debugPrint('RPC returned: $exists');
      return exists;
    } catch (error) {
      debugPrint('RPC error: $error');
      rethrow;
    }
  }

  void signUpUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the Terms and Privacy Policy.'),
        ),
      );
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    // ✅ Check network first
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

    LoadingDialog.show(context, message: 'Checking...');

    try {
      final exists = await checkEmailExists(email);
      debugPrint('Email exists: $exists');

      if (exists) {
        LoadingDialog.dismiss(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This email is already registered! Please sign in.'),
          ),
        );
        return;
      }

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      LoadingDialog.dismiss(context);

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created successfully! Please verify your email.',
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up failed. Try again later.')),
        );
      }
    } on AuthException catch (error) {
      LoadingDialog.dismiss(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (e) {
      LoadingDialog.dismiss(context);
      debugPrint('UNEXPECTED ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again!'),
        ),
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
                        title: "Let's Get Started!",
                        spacing: 8,
                        subtitle: "Let’s dive into your account",
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      CustomTextField(
                        controller: emailController,
                        label: 'Email',
                        hintText: '',
                        isEmail: true,
                        suffixIcon: Icons.email_outlined,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      CustomTextField(
                        controller: passwordController,
                        label: 'Password',
                        hintText: 'Password',
                        isPassword: true,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(62, 62, 62, 1),
                                  fontSize: 12,
                                  fontFamily: 'Urbanist',
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'By continuing, you agree to our ',
                                  ),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    TermsAndConditionsScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Terms of Service',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Color.fromRGBO(
                                            123,
                                            61,
                                            244,
                                            1,
                                          ),
                                          fontSize: 12,
                                          fontFamily: 'Urbanist',
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    TermsAndConditionsScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Privacy Policy',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Color.fromRGBO(
                                            123,
                                            61,
                                            244,
                                            1,
                                          ),
                                          fontSize: 12,
                                          fontFamily: 'Urbanist',
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.025),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInScreen(),
                              ),
                            );
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(62, 62, 62, 1),
                                fontSize: 15,
                                fontFamily: 'Urbanist',
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign in',
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
                        text: 'Sign up',
                        backgroundColor: const Color.fromRGBO(123, 61, 244, 1),
                        onPressed: signUpUser,
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
