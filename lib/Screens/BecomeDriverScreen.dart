import 'package:flutter/material.dart';
import 'package:swift_ride/Widgets/theme.dart';

class BecomeDriverScreen extends StatelessWidget {
  const BecomeDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Become a Driver"),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Join Swift Ride as a Driver",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "🚗 Drive with Swift Ride and earn money on your own schedule.",
            ),
            SizedBox(height: 12),
            Text("✅ Flexible working hours"),
            Text("✅ Great incentives"),
            Text("✅ 24/7 support"),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: null, // TODO: Add driver application logic
                child: Text("Apply Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
