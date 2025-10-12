import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Widgets/theme.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  final supabase = Supabase.instance.client;
  String? currentUserId;
  bool isLoading = true;
  List<Map<String, dynamic>> trips = [];

  @override
  void initState() {
    super.initState();
    currentUserId = supabase.auth.currentUser?.id;
    _fetchTripAssignmentHistory();
  }

  Future<void> _fetchTripAssignmentHistory() async {
    if (currentUserId == null) {
      setState(() => isLoading = false);
      return;
    }
    
    setState(() => isLoading = true);
    
    try {
      // Fetch trips assigned to this driver (like admin web)
      final tripsResponse = await supabase
          .from('trips')
          .select('*')
          .eq('driver_id', currentUserId!)
          .order('depart_time', ascending: false);

      final List<Map<String, dynamic>> tripsList = List<Map<String, dynamic>>.from(tripsResponse);
      
      // Fetch bookings for these trips (like admin web)
      List<Map<String, dynamic>> bookingsList = [];
      if (tripsList.isNotEmpty) {
        final tripIds = tripsList.map((trip) => trip['id'] as int).toList();
        final bookingsResponse = await supabase
            .from('bookings')
            .select('*')
            .inFilter('trip_id', tripIds)
            .order('created_at', ascending: false);
        
        bookingsList = List<Map<String, dynamic>>.from(bookingsResponse);
      }

      // Combine trips with their bookings
      for (final trip in tripsList) {
        trip['bookings'] = bookingsList.where((booking) => booking['trip_id'] == trip['id']).toList();
      }

      setState(() {
        trips = tripsList;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching trip assignment history: $e');
      setState(() {
        trips = [];
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load history: $e')),
        );
      }
    }
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final from = trip['from_city'] ?? trip['from'] ?? '';
    final to = trip['to_city'] ?? trip['to'] ?? '';
    final departTime = DateTime.parse(trip['depart_time']).toLocal();
    final arriveTime = DateTime.parse(trip['arrive_time']).toLocal();
    final departStr = DateFormat('MMM dd, yyyy hh:mm a').format(departTime);
    final arriveStr = DateFormat('MMM dd, yyyy hh:mm a').format(arriveTime);
    final bookings = trip['bookings'] as List<Map<String, dynamic>>? ?? [];
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Header
            Row(
              children: [
                const Icon(Icons.directions_bus, size: 20, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  'Trip ID: ${trip['id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.deepPurple,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Assigned to You',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Trip Details Table
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 2, child: Text('From', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('To', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('Depart', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('Arrive', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  // Table Row
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(from)),
                        Expanded(flex: 2, child: Text(to)),
                        Expanded(flex: 2, child: Text(departStr)),
                        Expanded(flex: 2, child: Text(arriveStr)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bookings Section
            Text(
              'Recent Bookings (${bookings.length})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            
            if (bookings.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No bookings yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Bookings Table Header
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(flex: 1, child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 1, child: Text('Trip', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('User', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 1, child: Text('Seats', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    // Bookings Rows
                    ...bookings.take(5).map((booking) => Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Text('${booking['id']}')),
                          Expanded(flex: 1, child: Text('${booking['trip_id']}')),
                          Expanded(
                            flex: 2, 
                            child: Text(
                              '${booking['user_id']}',
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                            ),
                          ),
                          Expanded(flex: 1, child: Text('${booking['seats']}')),
                          Expanded(
                            flex: 1, 
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(booking['status']),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${booking['status'] ?? '-'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'booked':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Trip Assignment History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchTripAssignmentHistory,
            tooltip: 'Refresh History',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A00FF), Color(0xFFFF3B3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : trips.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.white54,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Trip History Found',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Trip assignment history will appear here',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _fetchTripAssignmentHistory,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchTripAssignmentHistory,
                    color: Colors.deepPurple,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: trips.length,
                      itemBuilder: (context, index) {
                        final trip = trips[index];
                        return _buildTripCard(trip);
                      },
                    ),
                  ),
      ),
    );
  }
}
