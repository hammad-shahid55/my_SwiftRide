import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Widgets/theme.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool isLoading = false;
  double walletBalance = 0.0;
  final TextEditingController amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance();
  }

  Future<void> _fetchWalletBalance() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final res =
          await supabase
              .from('profiles')
              .select('wallet_balance')
              .eq('id', user.id)
              .maybeSingle();

      if (res != null && res['wallet_balance'] != null) {
        setState(() {
          walletBalance = (res['wallet_balance'] as num).toDouble();
        });
      }
    } catch (e) {
      debugPrint('Error fetching wallet balance: $e');
    }
  }

  Future<void> makePayment() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final enteredAmount = double.parse(amountController.text);
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      setState(() => isLoading = true);

      // ✅ Call Supabase Edge Function for payment
      final url = Uri.parse(
        'https://ffsqsalfmwjnauamlobc.supabase.co/functions/v1/create-payment-intent',
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization':
              'Bearer ${supabase.auth.currentSession?.accessToken ?? ''}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'amount': enteredAmount}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create PaymentIntent: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final clientSecret = data['clientSecret'];

      // ✅ Initialize PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Swift Ride',
          style: ThemeMode.light,
          billingDetails: BillingDetails(email: user.email ?? ''),
        ),
      );

      // ✅ Show PaymentSheet
      await Stripe.instance.presentPaymentSheet();

      // ✅ Update wallet balance in Supabase using increment_wallet function
      await supabase.rpc(
        'increment_wallet',
        params: {'user_id': user.id, 'amount': enteredAmount},
      );

      await _fetchWalletBalance();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment successful!')));

      amountController.clear();
    } catch (e) {
      if (e is StripeException) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payment cancelled')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text(
          'Wallet',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // Arrow color
          size: 28, // Slightly bigger arrow
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Wallet Card
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wallet Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Rs ${walletBalance.toStringAsFixed(0)}.00',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white70,
                      size: 40,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Amount Input with Validation
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter amount (Rs)',
                  labelStyle: TextStyle(color: Colors.deepPurple.shade700),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixText: 'Rs ',
                  prefixStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade900,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 500) {
                    return 'Amount must be at least Rs 500';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Payment Button
              ElevatedButton.icon(
                onPressed: isLoading ? null : makePayment,
                icon: const Icon(Icons.payment),
                label:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Add to Wallet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
