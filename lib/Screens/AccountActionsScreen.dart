import 'package:flutter/material.dart';

class AccountActionsScreen extends StatelessWidget {
  const AccountActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account Actions")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Manage your account settings below:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.lock_reset, color: Colors.deepPurple),
              title: const Text("Reset Password"),
              onTap: () {
                // TODO: Reset password logic
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: Colors.redAccent,
              ),
              title: const Text("Delete Account"),
              onTap: () {
                // TODO: Delete account logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
