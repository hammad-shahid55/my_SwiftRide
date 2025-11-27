import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Widgets/theme.dart';
import 'package:swift_ride/Widgets/StarRating.dart';
import 'package:swift_ride/Services/BookingStatusService.dart';
import 'package:swift_ride/Services/AutoCompletionService.dart';

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
  List<Map<String, dynamic>> cancelled = [];
  Map<dynamic, Map<String, dynamic>> tripIdToTrip = {};
  Map<dynamic, int> bookingIdToRating = {}; // Store ratings for bookings
  Map<dynamic, dynamic> bookingIdToDriverId = {}; // Store driver_id for bookings
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchBookings();
    _checkAutoCompletion();
  }

  /// Check for rides that should be auto-completed
  Future<void> _checkAutoCompletion() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Check user's rides for auto-completion
      await AutoCompletionService.checkUserRidesForCompletion(user.id);
    } catch (e) {
      print('Error checking auto-completion: $e');
    }
  }

  Future<void> fetchBookings() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('bookings')
        .select()
        .eq('user_id', user.id)
        .order('ride_time', ascending: true);

    final allBookings = List<Map<String, dynamic>>.from(response);

    // Fetch related trips to show full addresses and driver_id
    final tripIds = allBookings
        .map((b) => b['trip_id'])
        .where((id) => id != null)
        .toSet()
        .toList();
    Map<dynamic, Map<String, dynamic>> tripsMap = {};
    if (tripIds.isNotEmpty) {
      final trips = await supabase
          .from('trips')
          .select('id, from, to, total_seats, driver_id')
          .filter('id', 'in', '(${tripIds.join(',')})');
      for (final t in (trips as List)) {
        final m = t as Map<String, dynamic>;
        tripsMap[m['id']] = m;
      }
    }

    // Fetch existing ratings for completed bookings
    final completedBookingIds = allBookings
        .where((b) {
          final String status = (b['status'] as String?) ?? 'booked';
          final dynamic rt = b['ride_time'];
          DateTime? rideTime;
          if (rt is String && rt.isNotEmpty) {
            try {
              rideTime = DateTime.parse(rt);
            } catch (_) {}
          }
          final now = DateTime.now();
          return status == 'completed' || (rideTime != null && rideTime.isBefore(now));
        })
        .map((b) => b['id'])
        .where((id) => id != null)
        .toList();
    
    Map<dynamic, int> ratingsMap = {};
    if (completedBookingIds.isNotEmpty) {
      try {
        final ratings = await supabase
            .from('ratings')
            .select('booking_id, rating')
            .inFilter('booking_id', completedBookingIds);
        for (final r in (ratings as List)) {
          final m = r as Map<String, dynamic>;
          ratingsMap[m['booking_id']] = (m['rating'] as int?) ?? 0;
        }
      } catch (e) {
        print('Error fetching ratings: $e');
      }
    }

    final now = DateTime.now();
    List<Map<String, dynamic>> upcomingLocal = [];
    List<Map<String, dynamic>> completedLocal = [];
    List<Map<String, dynamic>> cancelledLocal = [];

    for (final b in allBookings) {
      final dynamic rt = b['ride_time'];
      DateTime? rideTime;
      if (rt is String && rt.isNotEmpty) {
        try {
          rideTime = DateTime.parse(rt);
        } catch (_) {}
      }
      final String status = (b['status'] as String?) ?? 'booked';

      // Merge trip fields
      final enriched = Map<String, dynamic>.from(b);
      final trip = tripsMap[enriched['trip_id']];
      if (trip != null) {
        enriched['from_address'] = trip['from'];
        enriched['to_address'] = trip['to'];
        enriched['trip_total_seats'] = trip['total_seats'];
        enriched['driver_id'] = trip['driver_id'];
      }
      
      // Add rating if exists
      enriched['rating'] = ratingsMap[enriched['id']] ?? 0;

      if (status == 'cancelled') {
        cancelledLocal.add(enriched);
        continue;
      }
      if (rideTime != null && rideTime.isBefore(now)) {
        completedLocal.add(enriched);
      } else if (status == 'completed') {
        completedLocal.add(enriched);
      } else {
        upcomingLocal.add(enriched);
      }
    }

    // Build rating and driver maps
    Map<dynamic, int> ratingMap = {};
    Map<dynamic, dynamic> driverMap = {};
    for (final b in completedLocal) {
      ratingMap[b['id']] = (b['rating'] as int?) ?? 0;
      driverMap[b['id']] = b['driver_id'];
    }

    // Sort completed and cancelled lists by date (newest first)
    // Helper function to get sortable date
    DateTime? getSortableDate(Map<String, dynamic> booking) {
      final dynamic rt = booking['ride_time'];
      if (rt is String && rt.isNotEmpty) {
        try {
          return DateTime.parse(rt);
        } catch (_) {}
      }
      final dynamic ct = booking['created_at'];
      if (ct is String && ct.isNotEmpty) {
        try {
          return DateTime.parse(ct);
        } catch (_) {}
      }
      return null;
    }

    // Sort completed list (newest first)
    completedLocal.sort((a, b) {
      final dateA = getSortableDate(a);
      final dateB = getSortableDate(b);
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1; // null dates go to end
      if (dateB == null) return -1;
      return dateB.compareTo(dateA); // descending order (newest first)
    });

    // Sort cancelled list (newest first)
    cancelledLocal.sort((a, b) {
      final dateA = getSortableDate(a);
      final dateB = getSortableDate(b);
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1; // null dates go to end
      if (dateB == null) return -1;
      return dateB.compareTo(dateA); // descending order (newest first)
    });

    setState(() {
      upcoming = upcomingLocal;
      completed = completedLocal;
      cancelled = cancelledLocal;
      tripIdToTrip = tripsMap;
      bookingIdToRating = ratingMap;
      bookingIdToDriverId = driverMap;
      isLoading = false;
    });
  }

  String formatDateTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd MMM, hh:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  Widget buildBookingCard(Map<String, dynamic> booking) {
    final String? rideIso = booking['ride_time'] as String?;
    final String? createdIso = booking['created_at'] as String?;
    final String? rideDisplay =
        (rideIso != null && rideIso.isNotEmpty) ? formatDateTime(rideIso) : null;
    final String? createdDisplay = (createdIso != null && createdIso.isNotEmpty)
        ? formatDateTime(createdIso)
        : null;
    final String? fromAddress = booking['from_address'] as String?;
    final String? toAddress = booking['to_address'] as String?;
    final String status = (booking['status'] as String?) ?? 'booked';
    DateTime? rideTime;
    if (rideIso != null && rideIso.isNotEmpty) {
      try {
        rideTime = DateTime.parse(rideIso);
      } catch (_) {}
    }
    final bool isUpcoming = rideTime == null || rideTime.isAfter(DateTime.now());
    // Determine displayed status: treat past rides as completed in UI
    final String displayedStatus = (rideTime != null && rideTime.isBefore(DateTime.now()))
        ? 'completed'
        : status;
    final Color statusColor = displayedStatus == 'booked'
        ? Colors.green
        : displayedStatus == 'completed'
            ? Colors.blue
            : Colors.red;

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
            if ((fromAddress != null && fromAddress.isNotEmpty) ||
                (toAddress != null && toAddress.isNotEmpty)) ...[
              const SizedBox(height: 4),
              if (fromAddress != null && fromAddress.isNotEmpty)
                Text("From: $fromAddress"),
              if (toAddress != null && toAddress.isNotEmpty)
                Text("To: $toAddress"),
            ],
            const SizedBox(height: 4),
            Text("Seats: ${booking['seats']}"),
            Text("Total Price: ${booking['total_price']} PKR"),
            Text(
              "Status: $displayedStatus",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            if (rideDisplay != null)
              Text("Ride Time: $rideDisplay")
            else if (createdDisplay != null)
              Text("Booked At: $createdDisplay"),
            // Show rating section for completed rides
            if (displayedStatus == 'completed') ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    "Rate your ride: ",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  StarRating(
                    initialRating: (booking['rating'] as int?) ?? 0,
                    readOnly: false,
                    size: 28.0,
                    onRatingChanged: (rating) async {
                      await _saveRating(booking, rating);
                    },
                  ),
                ],
              ),
            ],
            if (status == 'booked' && isUpcoming) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Cancel Booking?'),
                            content: const Text(
                              'Are you sure you want to cancel this booking?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('No'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Yes, Cancel'),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                    if (ok) {
                      await _cancelBooking(booking);
                    }
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveRating(Map<String, dynamic> booking, int rating) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final dynamic bookingId = booking['id'];
      final dynamic tripId = booking['trip_id'];
      final dynamic driverId = booking['driver_id'];

      if (bookingId == null || tripId == null || driverId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to save rating: Missing booking information.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Check if rating already exists
      final existingRating = await supabase
          .from('ratings')
          .select('id')
          .eq('booking_id', bookingId)
          .maybeSingle();

      if (existingRating != null) {
        // Update existing rating
        await supabase
            .from('ratings')
            .update({
              'rating': rating,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('booking_id', bookingId);
      } else {
        // Insert new rating
        await supabase.from('ratings').insert({
          'booking_id': bookingId,
          'user_id': user.id,
          'driver_id': driverId,
          'trip_id': tripId,
          'rating': rating,
        });
      }

      // Update local state
      setState(() {
        bookingIdToRating[bookingId] = rating;
        // Update in completed list
        final index = completed.indexWhere((b) => b['id'] == bookingId);
        if (index != -1) {
          completed[index]['rating'] = rating;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rating saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error saving rating: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save rating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelBooking(Map<String, dynamic> booking) async {
    try {
      final int seats = (booking['seats'] as int?) ?? 0;
      final dynamic tripId = booking['trip_id'];
      final dynamic bookingId = booking['id'];
      if (bookingId == null) return;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Use BookingStatusService to cancel and send email
      final success = await BookingStatusService.cancelBooking(
        bookingId: bookingId.toString(),
        reason: 'Cancelled by user',
      );

      // Update seats in trip if cancellation was successful
      if (success && tripId != null && seats > 0) {
        try {
          final trip = await supabase.from('trips').select('total_seats').eq('id', tripId).single();
          final int currentSeats = (trip['total_seats'] as int?) ?? 0;
          await supabase
              .from('trips')
              .update({'total_seats': currentSeats + seats})
              .eq('id', tripId);
        } catch (e) {
          print('Error updating trip seats: $e');
        }
      }

      Navigator.pop(context); // Close loading dialog

      await fetchBookings();
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled and email sent!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled but email failed.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog if open
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cancellation failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "Completed"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTab(upcoming, "No upcoming rides."),
          buildTab(completed, "No completed rides."),
          buildTab(cancelled, "No cancelled rides."),
        ],
      ),
    );
  }
}
