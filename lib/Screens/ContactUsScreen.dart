import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact Us")),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "We’d love to hear from you!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text("📧 Email: support@swiftride.com"),
            SizedBox(height: 8),
            Text("📞 Phone: +1 234 567 890"),
            SizedBox(height: 8),
            Text("🌐 Website: www.swiftride.com"),
          ],
        ),
      ),
    );
  }
}
