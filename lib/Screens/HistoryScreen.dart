import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Widgets/theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> upcoming = [];
  List<Map<String, dynamic>> completed = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('bookings')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false); // fixed ride_time issue

    final allBookings = List<Map<String, dynamic>>.from(response);

    setState(() {
      upcoming = allBookings.where((b) => b['status'] == 'booked').toList();
      completed = allBookings.where((b) => b['status'] == 'completed').toList();
      isLoading = false;
    });
  }

  Widget buildBookingCard(Map<String, dynamic> booking) {
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
                        : booking['status'] == 'completed'
                        ? Colors.blue
                        : Colors.red,
              ),
            ),
            if (booking['created_at'] != null)
              Text("Booked At: ${booking['created_at']}"),
          ],
        ),
      ),
    );
  }

  Widget buildTab(List<Map<String, dynamic>> list, String emptyMsg) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      );
    }
    if (list.isEmpty) {
      return Center(
        child: Text(emptyMsg, style: const TextStyle(fontSize: 16)),
      );
    }
    return RefreshIndicator(
      onRefresh: fetchBookings,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) => buildBookingCard(list[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Trips History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // back arrow white
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        ),

        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // active tab text color
          unselectedLabelColor: Colors.white70, // inactive tab text color
          indicatorColor: Colors.white,
          tabs: const [Tab(text: "Upcoming"), Tab(text: "Completed")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTab(upcoming, "No upcoming rides."),
          buildTab(completed, "No completed rides."),
        ],
      ),
    );
  }
}
