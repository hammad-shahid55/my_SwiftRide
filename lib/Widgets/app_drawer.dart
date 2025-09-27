import 'package:flutter/material.dart';
import 'package:swift_ride/Screens/BecomeDriverScreen.dart';
import 'package:swift_ride/Screens/ContactUsScreen.dart';
import 'package:swift_ride/Screens/HistoryScreen.dart';
import 'package:swift_ride/Screens/SettingsScreen.dart';
import 'package:swift_ride/Screens/WalletScreen.dart';
import 'package:swift_ride/Screens/AccountActionsScreen.dart';
import 'package:swift_ride/Screens/PrivacyPolicyScreen.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final VoidCallback onLogout;
  final Future<void> Function(Widget screen) onNavigate;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.onLogout,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Color.fromARGB(255, 156, 123, 214)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Custom centered header
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 106, 63, 207),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: Colors.deepPurple,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Hello, $userName',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Enjoy your ride...!!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Divider below header
            const Divider(color: Colors.white70, thickness: 1, height: 0),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.white),
                    title: const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => onNavigate(const SettingsScreen()),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => onNavigate(const WalletScreen()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.history, color: Colors.white),
                    title: const Text(
                      'Trips History',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => onNavigate(const HistoryScreen()),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.support_agent,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Contact Us',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => onNavigate(const ContactUsScreen()),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.account_circle,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Account Actions',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => onNavigate(const AccountActionsScreen()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip, color: Colors.white),
                    title: const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => onNavigate(const PrivacyPolicyScreen()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.drive_eta, color: Colors.white),
                    title: const Text(
                      'Become a Driver',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => onNavigate(const BecomeDriverScreen()),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white70, thickness: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
