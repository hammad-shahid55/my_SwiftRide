import 'package:flutter/material.dart';
import 'package:swift_ride/Widgets/theme.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  final List<Map<String, String>> _termsPoints = const [
    {
      "title": "Acceptance of Terms",
      "desc":
          "By using SwiftRide, you agree to these Terms and Conditions and our Privacy Policy. If you do not agree, you must stop using the service.",
    },
    {
      "title": "Eligibility",
      "desc":
          "You must be at least 18 years old to create an account and use SwiftRide services. Minors must be accompanied by a responsible adult.",
    },
    {
      "title": "Account Responsibility",
      "desc":
          "You are responsible for maintaining the confidentiality of your login details and all activities under your account.",
    },
    {
      "title": "Ride Booking & Payment",
      "desc":
          "All rides must be booked through the app. Payments are processed securely via integrated payment gateways. Cancellation fees may apply.",
    },
    {
      "title": "User Conduct",
      "desc":
          "You agree not to misuse the platform, harass drivers or passengers, damage vehicles, or engage in unlawful activity while using SwiftRide.",
    },
    {
      "title": "Driver & Passenger Safety",
      "desc":
          "Both drivers and passengers must follow safety guidelines, including wearing seatbelts and complying with traffic laws.",
    },
    {
      "title": "Service Availability",
      "desc":
          "SwiftRide aims to provide reliable services but does not guarantee uninterrupted availability due to maintenance, technical issues, or unforeseen events.",
    },
    {
      "title": "Termination of Service",
      "desc":
          "SwiftRide reserves the right to suspend or terminate your account if you violate these Terms, engage in fraud, or misuse the platform.",
    },
    {
      "title": "Limitation of Liability",
      "desc":
          "SwiftRide is not liable for delays, accidents, loss of property, or damages arising from the use of the service, except where required by law.",
    },
    {
      "title": "Amendments",
      "desc":
          "We may update these Terms & Conditions from time to time. Continued use of the app after updates means you accept the revised terms.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Terms & Conditions",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome to SwiftRide’s Terms & Conditions.\n\n"
                "Please read these terms carefully before using our services. "
                "By continuing, you acknowledge and agree to the following:",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),

              // Numbered List
              ..._termsPoints.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final point = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(
                          text: "$index. ${point["title"]}\n",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(text: point["desc"]),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),
              const Text(
                "If you have any questions about these Terms, please contact us at support@swiftride.com.",
                style: TextStyle(fontSize: 15, height: 1.5),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
