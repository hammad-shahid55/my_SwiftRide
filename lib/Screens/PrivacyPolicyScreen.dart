import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  final List<Map<String, String>> _policyPoints = const [
    {
      "title": "Information Collection",
      "desc":
          "We collect your name, email, phone number, profile picture, payment method, and ride details to provide better services.",
    },
    {
      "title": "Data Usage",
      "desc":
          "Your data is used for booking rides, processing payments, customer support, and improving our platform performance.",
    },
    {
      "title": "Data Sharing",
      "desc":
          "We do not sell your information. Data is only shared with drivers, service partners, and regulatory authorities when required.",
    },
    {
      "title": "Security",
      "desc":
          "All sensitive data is encrypted, stored securely, and monitored to protect against unauthorized access.",
    },
    {
      "title": "Your Rights",
      "desc":
          "You may request account deletion, data export, or correction of your personal information at any time.",
    },
    {
      "title": "Location Data",
      "desc":
          "SwiftRide collects and uses precise location data for pickups, drop-offs, route optimization, and safety monitoring.",
    },
    {
      "title": "Cookies & Tracking",
      "desc":
          "We use cookies, analytics tools, and tracking technologies to personalize your experience and improve app performance.",
    },
    {
      "title": "Third-Party Services",
      "desc":
          "We may integrate with payment processors, map providers, and communication platforms, which may collect limited data as per their own policies.",
    },
    {
      "title": "Data Retention",
      "desc":
          "We retain your personal and ride history data only as long as necessary to provide services or meet legal obligations.",
    },
    {
      "title": "Children’s Privacy",
      "desc":
          "SwiftRide does not knowingly collect data from individuals under 13. If discovered, such accounts will be deleted immediately.",
    },
    {
      "title": "Policy Updates",
      "desc":
          "We may update this Privacy Policy from time to time. Any significant changes will be communicated to users.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome to SwiftRide’s Privacy Policy.\n\n"
                "We value your privacy and are committed to protecting your personal information. "
                "Here’s how we handle your data:",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),

              // Numbered List
              ..._policyPoints.asMap().entries.map((entry) {
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
                "If you have any questions, please contact us at support@swiftride.com.",
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
