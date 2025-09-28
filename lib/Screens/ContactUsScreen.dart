import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Widgets/theme.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final TextEditingController complaintController = TextEditingController();

  String? userEmail;

  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentUser;
    setState(() {
      userEmail = user?.email ?? "Not Logged In";
    });
  }

  Future<void> _showAnimatedDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  if (isSuccess) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> submitComplaint() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      _showAnimatedDialog(
        title: "Error",
        message: "You must be logged in to submit a complaint.",
        isSuccess: false,
      );
      return;
    }

    final complaint = complaintController.text.trim();
    if (complaint.isEmpty) {
      _showAnimatedDialog(
        title: "Incomplete",
        message: "Please enter your complaint before submitting.",
        isSuccess: false,
      );
      return;
    }

    try {
      await supabase.from("complaints").insert({
        "user_id": user.id,
        "email": user.email,
        "complaint": complaint,
      });

      complaintController.clear();

      _showAnimatedDialog(
        title: "Success",
        message: "Your complaint has been submitted successfully.",
        isSuccess: true,
      );
    } catch (e) {
      _showAnimatedDialog(
        title: "Error",
        message: "Failed to submit complaint: $e",
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        ),
        title: const Text(
          "Contact Us",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ), // White AppBar title
        ),
        iconTheme: const IconThemeData(color: Colors.white), // White back icon
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "We value your feedback.",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),

            // User Email
            const Text(
              "Your Email:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(userEmail ?? "Fetching..."),
            const SizedBox(height: 20),

            // Complaint Box
            TextField(
              controller: complaintController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Please describe your complaint...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  onPressed: submitComplaint,
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.white), // White Submit text
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Contact Info
            const Divider(),
            const SizedBox(height: 10),
            const Text("📧 Email: support@swiftride.com"),
            const SizedBox(height: 8),
            const Text("📞 Phone: +92 300 1234567"),
            const SizedBox(height: 8),
            const Text("🌐 Website: www.swiftride.com"),
          ],
        ),
      ),
    );
  }
}
