import 'package:flutter/material.dart';

class BookingWidget extends StatefulWidget {
  final int totalSeats;
  final int pricePerSeat;
  final Function(int bookedSeats) onBookingConfirmed;

  const BookingWidget({
    super.key,
    required this.totalSeats,
    required this.pricePerSeat,
    required this.onBookingConfirmed,
  });

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  int bookedSeats = 1;

  void _increaseSeats() {
    if (bookedSeats < widget.totalSeats) {
      setState(() {
        bookedSeats++;
      });
    }
  }

  void _decreaseSeats() {
    if (bookedSeats > 1) {
      setState(() {
        bookedSeats--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int availableSeats = widget.totalSeats - bookedSeats;

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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              widget.onBookingConfirmed(bookedSeats);
            },
            child: const Text(
              "Book Now",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
