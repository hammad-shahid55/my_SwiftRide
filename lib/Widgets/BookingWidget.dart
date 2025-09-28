import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    if (bookedSeats < widget.totalSeats) setState(() => bookedSeats++);
  }

  void _decreaseSeats() {
    if (bookedSeats > 1) setState(() => bookedSeats--);
  }

  Future<void> _bookSeats() async {
    final totalPrice = bookedSeats * widget.pricePerSeat;

    bool confirmed = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Confirm Booking"),
            content: Text(
              "Seats: $bookedSeats\nPrice: $totalPrice PKR\nFrom: ${widget.fromCity}\nTo: ${widget.toCity}",
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
    );

    if (confirmed != null && confirmed) {
      try {
        final user = supabase.auth.currentUser;
        if (user == null) throw "User not logged in";

        // Save booking
        await supabase.from('bookings').insert({
          'user_id': user.id,
          'trip_id': widget.trip['id'],
          'from_city': widget.fromCity,
          'to_city': widget.toCity,
          'seats': bookedSeats,
          'total_price': totalPrice,
          'status': 'booked',
        });

        // Update seats in trips table
        await supabase
            .from('trips')
            .update({'total_seats': widget.totalSeats - bookedSeats})
            .eq('id', widget.trip['id']);

        widget.onBookingCompleted();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Booking Successful!")));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Booking Failed: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int availableSeats = widget.totalSeats;

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
            "${widget.fromCity} → ${widget.toCity}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Price per Seat: ${widget.pricePerSeat} PKR",
                style: const TextStyle(fontSize: 16, color: Colors.green),
              ),
              Text(
                "Seats Available: $availableSeats",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
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
