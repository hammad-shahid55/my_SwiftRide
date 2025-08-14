import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Widgets/CustomBackButton.dart';
import 'package:swift_ride/Widgets/CustomTextField.dart';
import 'package:swift_ride/Widgets/CustomTextWidget.dart';
import 'package:swift_ride/Widgets/Homeindicator.dart';
import 'package:swift_ride/Widgets/MainButton.dart';
import 'package:swift_ride/Widgets/LoadingDialog.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void sendPasswordReset() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    LoadingDialog.show(context, message: 'Sending reset email...');

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      LoadingDialog.dismiss(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Password reset email sent!')));
    } on AuthException catch (error) {
      LoadingDialog.dismiss(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (e) {
      LoadingDialog.dismiss(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong. Please try again!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(leading: CustomBackButton()),
      backgroundColor: Color.fromRGBO(246, 246, 246, 1),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextWidget(
              title: "Forgot Password 🔑",
              titleSize: screenWidth * 0.07,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "We've got you covered. Enter your registered email to reset your password. We will send an OTP code to your email for the next steps.",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: screenWidth * 0.04,
                color: const Color.fromRGBO(62, 62, 62, 1),
                fontFamily: 'Urbanist',
              ),
            ),
            SizedBox(height: screenHeight * 0.04),

            CustomTextField(
              controller: emailController,
              label: 'Your Registered Email',
              hintText: 'Email',
              suffixIcon: Icons.email_outlined,
            ),

            const Spacer(),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MainButton(
                  text: 'Send OTP Code',
                  backgroundColor: Color.fromRGBO(123, 61, 244, 1),
                  onPressed: sendPasswordReset,
                ),
                SizedBox(height: screenHeight * 0.05),
                HomeIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
