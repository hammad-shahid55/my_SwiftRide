import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('bookings')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    setState(() {
      bookings = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
              : bookings.isEmpty
              ? const Center(
                child: Text(
                  "Your ride history will appear here.",
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${booking['from_city']} → ${booking['to_city']}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("Seats: ${booking['seats']}"),
                          Text("Total Price: ${booking['total_price']} PKR"),
                          Text(
                            "Status: ${booking['status']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  booking['status'] == 'booked'
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
