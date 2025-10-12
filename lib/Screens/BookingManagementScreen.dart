import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Widgets/BookingStatusWidget.dart';
import 'package:intl/intl.dart';

/// Screen to manage bookings and send email notifications
class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;
  String selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    setState(() => isLoading = true);
    
    try {
      final response = await supabase
          .from('bookings')
          .select('*')
          .order('created_at', ascending: false);

      setState(() {
        bookings = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching bookings: $e');
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> get filteredBookings {
    if (selectedStatus == 'all') {
      return bookings;
    }
    return bookings.where((booking) => 
      (booking['status'] as String?)?.toLowerCase() == selectedStatus.toLowerCase()
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Management'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: fetchBookings,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filter
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Filter by status: '),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Bookings')),
                      DropdownMenuItem(value: 'booked', child: Text('Booked')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                      DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value ?? 'all';
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Bookings list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredBookings.isEmpty
                    ? const Center(
                        child: Text(
                          'No bookings found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = filteredBookings[index];
                          return BookingCard(
                            booking: booking,
                            onStatusChanged: fetchBookings,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onStatusChanged;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final status = (booking['status'] as String?) ?? 'booked';
    final bookingId = booking['id']?.toString() ?? 'N/A';
    final fromCity = booking['from_city'] as String? ?? 'N/A';
    final toCity = booking['to_city'] as String? ?? 'N/A';
    final seats = booking['seats'] as int? ?? 0;
    final totalPrice = booking['total_price'] as int? ?? 0;
    final rideTime = booking['ride_time'] as String?;
    final createdAt = booking['created_at'] as String?;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with booking ID and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #$bookingId',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _getStatusChip(status),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Route information
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$fromCity → $toCity',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Booking details
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Text('$seats seat${seats != 1 ? 's' : ''}'),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text('$totalPrice PKR'),
              ],
            ),
            
            if (rideTime != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text(_formatDateTime(rideTime)),
                ],
              ),
            ],
            
            if (createdAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Text('Booked: ${_formatDateTime(createdAt)}'),
                ],
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Status management buttons
            BookingStatusWidget(
              bookingId: bookingId,
              currentStatus: status,
              onStatusChanged: onStatusChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStatusChip(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    
    switch (status.toLowerCase()) {
      case 'booked':
        backgroundColor = Colors.blue;
        break;
      case 'cancelled':
      case 'canceled':
        backgroundColor = Colors.red;
        break;
      case 'completed':
        backgroundColor = Colors.green;
        break;
      default:
        backgroundColor = Colors.grey;
    }
    
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
}
