import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Screens/HomeScreen.dart';
import 'package:swift_ride/Services/SimpleEmailService.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class BookingWidget extends StatefulWidget {
  final int totalSeats;
  final int pricePerSeat;
  final String fromCity;
  final String toCity;
  final Map<String, dynamic> trip;
  final VoidCallback onBookingCompleted;

  const BookingWidget({
    super.key,
    required this.totalSeats,
    required this.pricePerSeat,
    required this.fromCity,
    required this.toCity,
    required this.trip,
    required this.onBookingCompleted,
  });

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  int bookedSeats = 1;
  final supabase = Supabase.instance.client;

  void _increaseSeats() {
    final int totalSeats =
        (widget.trip['total_seats'] ?? widget.totalSeats) as int;
    if (bookedSeats < totalSeats) setState(() => bookedSeats++);
  }

  void _decreaseSeats() {
    if (bookedSeats > 1) setState(() => bookedSeats--);
  }

  Future<void> _bookSeats() async {
    final int pricePerSeat =
        (widget.trip['price'] ?? widget.pricePerSeat) as int;
    final totalPrice = bookedSeats * pricePerSeat;
    final String fromCity =
        (widget.trip['from_city'] ?? widget.fromCity) as String;
    final String toCity = (widget.trip['to_city'] ?? widget.toCity) as String;

    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("Confirm Booking"),
                content: Text(
                  "Seats: $bookedSeats\nPrice: $totalPrice PKR\nFrom: $fromCity\nTo: $toCity",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Confirm"),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirmed) {
      try {
        final user = supabase.auth.currentUser;
        if (user == null) throw "User not logged in";

        // Save booking
        final bookingResponse = await supabase.from('bookings').insert({
          'user_id': user.id,
          'trip_id': widget.trip['id'],
          'from_city': fromCity,
          'to_city': toCity,
          'seats': bookedSeats,
          'total_price': totalPrice,
          'status': 'booked',
          // Save ride_time at booking time using the trip's scheduled depart_time
          'ride_time': widget.trip['depart_time'],
        }).select();

        // Get the booking ID from the response
        String bookingId = 'BOOK-${DateTime.now().millisecondsSinceEpoch}';
        if (bookingResponse.isNotEmpty) {
          bookingId = bookingResponse.first['id']?.toString() ?? bookingId;
        }

        // Update seats in trips table
        final int currentSeats =
            (widget.trip['total_seats'] ?? widget.totalSeats) as int;
        final int newSeats = (currentSeats - bookedSeats).clamp(
          0,
          currentSeats,
        );
        await supabase
            .from('trips')
            .update({'total_seats': newSeats})
            .eq('id', widget.trip['id']);

        // Get user profile for email notification
        String userName = 'User';
        try {
          final profileResponse = await supabase
              .from('profiles')
              .select('name')
              .eq('id', user.id)
              .maybeSingle();
          
          if (profileResponse != null && profileResponse['name'] != null) {
            userName = profileResponse['name'];
          } else {
            userName = user.email?.split('@').first ?? 'User';
          }
        } catch (e) {
          print('Error fetching user profile: $e');
          userName = user.email?.split('@').first ?? 'User';
        }

        // Send email notification
        if (user.email != null && user.email!.isNotEmpty) {
          try {
            final emailSent = await SimpleEmailService.sendBookingConfirmation(
              userEmail: user.email!,
              userName: userName,
              fromCity: fromCity,
              toCity: toCity,
              seats: bookedSeats,
              totalPrice: totalPrice,
              rideTime: widget.trip['depart_time'] ?? DateTime.now().toIso8601String(),
              bookingId: bookingId,
            );

            if (emailSent) {
              print('✅ Email notification sent successfully');
            } else {
              print('⚠️ Email notification failed, but booking was successful');
            }
          } catch (e) {
            print('❌ Error sending email notification: $e');
            // Don't fail the booking if email fails
          }
        }

        widget.onBookingCompleted();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(
          content: Text("Booking Successful! Check your email for confirmation."),
          backgroundColor: Colors.green,
        ));

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
          content: Text("Booking Failed: $e"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalSeats =
        (widget.trip['total_seats'] ?? widget.totalSeats) as int;
    final int pricePerSeat =
        (widget.trip['price'] ?? widget.pricePerSeat) as int;
    final String fromCity =
        (widget.trip['from_city'] ?? widget.fromCity) as String;
    final String toCity = (widget.trip['to_city'] ?? widget.toCity) as String;
    final String? fromAddress = widget.trip['from'] as String?;
    final String? toAddress = widget.trip['to'] as String?;
    int availableSeats = (totalSeats - bookedSeats).clamp(0, totalSeats);
    final String? distanceText = widget.trip['distance_text'] as String?;
    final String? durationText = widget.trip['duration_text'] as String?;
    final int? durationMin = widget.trip['duration_min'] as int?;
    final String derivedDuration =
        durationText ??
        (durationMin != null
            ? (durationMin >= 60
                ? "${durationMin ~/ 60}h ${durationMin % 60}m"
                : "${durationMin}m")
            : "");
    // Format depart/arrive in PKT (Asia/Karachi)
    String departStr = '';
    String arriveStr = '';
    try {
      final dynamic departIso = widget.trip['depart_time'];
      final dynamic arriveIso = widget.trip['arrive_time'];
      tzdata.initializeTimeZones();
      final loc = tz.getLocation('Asia/Karachi');
      if (departIso is String && departIso.isNotEmpty) {
        final dtUtc = DateTime.parse(departIso).toUtc();
        final dtPkt = tz.TZDateTime.from(dtUtc, loc);
        departStr = DateFormat('hh:mm a').format(dtPkt);
      }
      if (arriveIso is String && arriveIso.isNotEmpty) {
        final atUtc = DateTime.parse(arriveIso).toUtc();
        final atPkt = tz.TZDateTime.from(atUtc, loc);
        arriveStr = DateFormat('hh:mm a').format(atPkt);
      }
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$fromCity → $toCity",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          if ((fromAddress != null && fromAddress.isNotEmpty) ||
              (toAddress != null && toAddress.isNotEmpty)) ...[
            const SizedBox(height: 6),
            if (fromAddress != null && fromAddress.isNotEmpty)
              Text(
                "From: $fromAddress",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            if (toAddress != null && toAddress.isNotEmpty)
              Text(
                "To: $toAddress",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Price per Seat: $pricePerSeat PKR",
                style: const TextStyle(fontSize: 16, color: Colors.green),
              ),
              Text(
                "Seats Available: $availableSeats",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          if ((distanceText != null && distanceText.isNotEmpty) ||
              derivedDuration.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (distanceText != null && distanceText.isNotEmpty)
                  Text(
                    "Distance: $distanceText",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                if (derivedDuration.isNotEmpty)
                  Text(
                    "Duration: $derivedDuration",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
              ],
            ),
          ],
          if (departStr.isNotEmpty || arriveStr.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (departStr.isNotEmpty)
                  Text(
                    "Depart: $departStr",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                if (arriveStr.isNotEmpty)
                  Text(
                    "Arrive: $arriveStr",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              const Text(
                "Book Seats: ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _decreaseSeats,
              ),
              Text("$bookedSeats", style: const TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _increaseSeats,
              ),
              Text(
                "Total: ${bookedSeats * widget.pricePerSeat} PKR",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Gradient Book Now button
          Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5500FF), Color(0xFFFB7B7B)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: _bookSeats,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "Book Now",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
