import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:swift_ride/Screens/SplashScreen.dart';
import 'package:swift_ride/Services/EmailTestService.dart';
import 'package:swift_ride/Services/AutoCompletionService.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    print('⚠️ .env file not found, using default values');
  }

  final envSupabaseUrl = dotenv.env['SUPABASE_URL'] ?? supabaseUrl;
  final envSupabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? supabaseKey;
  final stripeKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  if (stripeKey.isNotEmpty) {
    Stripe.publishableKey = stripeKey;
  }
  await Supabase.initialize(url: envSupabaseUrl, anonKey: envSupabaseKey);

  // Check email configuration status (optional - for debugging)
  EmailTestService.printConfigurationStatus();

  // Check for rides that need auto-completion (run in background)
  AutoCompletionService.checkAndAutoCompleteRides();

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}
