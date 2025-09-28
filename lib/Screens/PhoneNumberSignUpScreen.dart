import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import 'package:swift_ride/Screens/UserProfileScreen.dart';
import 'package:swift_ride/Widgets/theme.dart';

class ContinueWithPhoneNumber extends StatefulWidget {
  const ContinueWithPhoneNumber({super.key});

  @override
  State<ContinueWithPhoneNumber> createState() =>
      _PhoneNumberSignUpScreenState();
}

class _PhoneNumberSignUpScreenState extends State<ContinueWithPhoneNumber> {
  final TextEditingController phoneController = TextEditingController();
  final OtpFieldController otpController = OtpFieldController();
  String phoneNumber = '';

  void sendOTP() async {
    phoneNumber = phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    final regex = RegExp(r'^\+92\d{10}$');
    if (!regex.hasMatch(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Phone number must start with +92 and contain exactly 10 digits after +92.\nExample: +923001234567',
          ),
        ),
      );
      return;
    }

    try {
      await Supabase.instance.client.auth.signInWithOtp(phone: phoneNumber);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OTP sent to $phoneNumber')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send OTP: $e')));
    }
  }

  void verifyOTP(String otp) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number first')),
      );
      return;
    }

    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.sms,
        token: otp,
        phone: phoneNumber,
      );

      if (response.session != null && response.user != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Account created!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserProfileScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to verify OTP: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent screen from shifting
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Phone Sign Up',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),

        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        ),
      ),
      body: SingleChildScrollView(
        physics:
            const NeverScrollableScrollPhysics(), // Prevent scrolling when keyboard opens
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 80),
            // Label above field
            const Text(
              'Enter Phone Number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10), // Space between label and field
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "+92XXXXXXXXXX",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            OTPTextField(
              length: 6,
              width: MediaQuery.of(context).size.width,
              fieldWidth: 40,
              style: const TextStyle(fontSize: 18, color: Colors.black),
              textFieldAlignment: MainAxisAlignment.spaceAround,
              controller: otpController,
              fieldStyle: FieldStyle.box,
              onChanged: (pin) {},
              onCompleted: (pin) => verifyOTP(pin),
            ),
            const SizedBox(height: 40),
            Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5500FF), Color(0xFFFB7B7B)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: sendOTP,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Send OTP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
