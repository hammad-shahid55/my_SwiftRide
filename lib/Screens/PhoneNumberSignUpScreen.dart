import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:otp_text_field/otp_field.dart';

import 'package:swift_ride/Screens/UserProfileScreen.dart';

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
        SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    final regex = RegExp(r'^\+92\d{10}$');

    if (!regex.hasMatch(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Phone number must start with +92 and contain exactly 10 digits after +92.\nExample: +923001234567',
          ),
        ),
      );
      return;
    }

    try {
      await Supabase.instance.client.auth.signInWithOtp(phone: phoneNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent to $phoneNumber')),
      );
    } catch (e) {
      print('Error sending OTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: $e')),
      );
    }
  }

  void verifyOTP(String otp) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a phone number first')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserProfileScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid OTP. Please try again.')),
        );
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify OTP: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phone Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Enter Phone Number",
                hintText: "+92XXXXXXXXXX",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            OTPTextField(
              length: 6,
              width: MediaQuery.of(context).size.width,
              fieldWidth: 40,
              style: TextStyle(fontSize: 17),
              textFieldAlignment: MainAxisAlignment.spaceAround,
              controller: otpController,
              onChanged: (pin) {
                print("OTP typing: $pin");
              },
              onCompleted: (pin) {
                print("OTP Entered: $pin");
                verifyOTP(pin);
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendOTP,
              child: Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
