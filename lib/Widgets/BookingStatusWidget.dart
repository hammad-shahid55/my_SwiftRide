import 'package:flutter/material.dart';
import 'package:swift_ride/Services/BookingStatusService.dart';

/// Widget to handle booking status changes with email notifications
class BookingStatusWidget extends StatelessWidget {
  final String bookingId;
  final String currentStatus;
  final VoidCallback? onStatusChanged;

  const BookingStatusWidget({
    super.key,
    required this.bookingId,
    required this.currentStatus,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (currentStatus == 'booked') ...[
          ElevatedButton.icon(
            onPressed: () => _cancelBooking(context),
            icon: const Icon(Icons.cancel, color: Colors.white),
            label: const Text('Cancel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _completeBooking(context),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text('Complete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
        if (currentStatus == 'cancelled' || currentStatus == 'canceled')
          const Chip(
            label: Text('Cancelled'),
            backgroundColor: Colors.red,
            labelStyle: TextStyle(color: Colors.white),
          ),
        if (currentStatus == 'completed')
          const Chip(
            label: Text('Completed'),
            backgroundColor: Colors.green,
            labelStyle: TextStyle(color: Colors.white),
          ),
      ],
    );
  }

  Future<void> _cancelBooking(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking? An email notification will be sent to the user.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final success = await BookingStatusService.cancelBooking(
          bookingId: bookingId,
          reason: 'Cancelled by admin',
        );

        Navigator.pop(context); // Close loading dialog

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled and email sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          onStatusChanged?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to cancel booking'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeBooking(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Booking'),
        content: const Text('Mark this booking as completed? A completion email will be sent to the user.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Yes, Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final success = await BookingStatusService.completeBooking(
          bookingId: bookingId,
        );

        Navigator.pop(context); // Close loading dialog

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking completed and email sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          onStatusChanged?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to complete booking'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Simple booking status button for quick actions
class BookingStatusButton extends StatelessWidget {
  final String bookingId;
  final String currentStatus;
  final VoidCallback? onStatusChanged;

  const BookingStatusButton({
    super.key,
    required this.bookingId,
    required this.currentStatus,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (currentStatus.toLowerCase()) {
      case 'booked':
        return Row(
          children: [
            IconButton(
              onPressed: () => _quickCancel(context),
              icon: const Icon(Icons.cancel, color: Colors.red),
              tooltip: 'Cancel Booking',
            ),
            IconButton(
              onPressed: () => _quickComplete(context),
              icon: const Icon(Icons.check_circle, color: Colors.green),
              tooltip: 'Complete Booking',
            ),
          ],
        );
      case 'cancelled':
      case 'canceled':
        return const Icon(Icons.cancel, color: Colors.red);
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  Future<void> _quickCancel(BuildContext context) async {
    try {
      final success = await BookingStatusService.cancelBooking(
        bookingId: bookingId,
        reason: 'Cancelled by admin',
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled and email sent!'),
            backgroundColor: Colors.green,
          ),
        );
        onStatusChanged?.call();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _quickComplete(BuildContext context) async {
    try {
      final success = await BookingStatusService.completeBooking(
        bookingId: bookingId,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking completed and email sent!'),
            backgroundColor: Colors.green,
          ),
        );
        onStatusChanged?.call();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
