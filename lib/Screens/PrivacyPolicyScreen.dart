import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text("""
Welcome to SwiftRide’s Privacy Policy.

We value your privacy and are committed to protecting your personal information.

1. Information Collection:
   - We collect your name, email, phone number, and ride details.

2. Data Usage:
   - Used for booking rides, customer support, and service improvements.

3. Data Sharing:
   - We do not sell your information. Data is only shared with drivers and required partners.

4. Security:
   - All sensitive data is encrypted and stored securely.

5. Your Rights:
   - You may request account deletion or data export anytime.

If you have questions, please contact us at support@swiftride.com.
            """, style: TextStyle(fontSize: 16, height: 1.5)),
        ),
      ),
    );
  }
}
