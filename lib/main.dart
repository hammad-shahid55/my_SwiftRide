import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:swift_ride/Screens/SplashScreen.dart';
import 'package:swift_ride/Services/EmailTestService.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  final envSupabaseUrl = dotenv.env['SUPABASE_URL'] ?? supabaseUrl;
  final envSupabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? supabaseKey;
  final stripeKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  if (stripeKey.isNotEmpty) {
    Stripe.publishableKey = stripeKey;
  }
  await Supabase.initialize(url: envSupabaseUrl, anonKey: envSupabaseKey);

  // Check email configuration status (optional - for debugging)
  EmailTestService.printConfigurationStatus();

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}
