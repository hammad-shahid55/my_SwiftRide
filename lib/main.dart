import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:swift_ride/Screens/SplashScreen.dart';

const supabaseUrl = 'https://ffsqsalfmwjnauamlobc.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZmc3FzYWxmbXdqbmF1YW1sb2JjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzNDMxNjYsImV4cCI6MjA2NzkxOTE2Nn0.CzOTqwA7puMP48Ay2P1KmrYihUb8Asdkr--fK3_reSw';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51RiEs3Qqz4NjHb2sF9VzGQUIdlZZhRkjPwxxhk1UbvucJoxFctjm5sIxeomxNcpoPrtKkttHGRRcpSchMfzdE5CS00jyNU97OB';
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}

// const SizedBox(height: 16),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.directions),
//               label: const Text("Show Route"),
//               onPressed: () async {
//                 if (fromController.text.isNotEmpty &&
//                     toController.text.isNotEmpty) {
//                   await saveLocationToHistory(toController.text);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => DirectionsMapScreen(
//                         fromAddress: fromController.text,
//                         toAddress: toController.text,
//                       ),
//                     ),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                         content:
//                             Text('Please enter both From and To addresses')),
//                   );
//                 }
//               },
//             ),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
// }
