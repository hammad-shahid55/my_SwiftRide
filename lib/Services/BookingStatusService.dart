import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Services/SimpleEmailService.dart';

/// Service to handle booking status changes and send appropriate email notifications
class BookingStatusService {
  static final supabase = Supabase.instance.client;

  /// Update booking status and send email notification
  static Future<bool> updateBookingStatus({
    required String bookingId,
    required String newStatus,
    String? cancellationReason,
  }) async {
    try {
      // Get booking details
      final bookingResponse = await supabase
          .from('bookings')
          .select('*')
          .eq('id', bookingId)
          .single();

      final booking = bookingResponse as Map<String, dynamic>;

      // Update booking status
      await supabase
          .from('bookings')
          .update({'status': newStatus})
          .eq('id', bookingId);

      // Get user details
      final userResponse = await supabase
          .from('profiles')
          .select('name')
          .eq('id', booking['user_id'])
          .maybeSingle();

      String userName = 'User';
      if (userResponse != null && userResponse['name'] != null) {
        userName = userResponse['name'];
      }

      // Get user email from auth
      final user = supabase.auth.currentUser;
      if (user?.email == null) {
        print('❌ User email not found for booking: $bookingId');
        return false;
      }

      // Get trip details for full addresses
      final tripResponse = await supabase
          .from('trips')
          .select('from, to')
          .eq('id', booking['trip_id'])
          .maybeSingle();

      String? fromAddress;
      String? toAddress;
      if (tripResponse != null) {
        fromAddress = tripResponse['from'] as String?;
        toAddress = tripResponse['to'] as String?;
      }

      // Send appropriate email based on status
      bool emailSent = false;
      switch (newStatus.toLowerCase()) {
        case 'cancelled':
        case 'canceled':
          emailSent = await SimpleEmailService.sendBookingCancellation(
            userEmail: user!.email!,
            userName: userName,
            fromCity: booking['from_city'] as String,
            toCity: booking['to_city'] as String,
            seats: booking['seats'] as int,
            totalPrice: booking['total_price'] as int,
            rideTime: booking['ride_time'] as String,
            bookingId: bookingId,
            fromAddress: fromAddress,
            toAddress: toAddress,
            cancellationReason: cancellationReason,
          );
          break;

        case 'completed':
          emailSent = await SimpleEmailService.sendBookingCompletion(
            userEmail: user!.email!,
            userName: userName,
            fromCity: booking['from_city'] as String,
            toCity: booking['to_city'] as String,
            seats: booking['seats'] as int,
            totalPrice: booking['total_price'] as int,
            rideTime: booking['ride_time'] as String,
            bookingId: bookingId,
            fromAddress: fromAddress,
            toAddress: toAddress,
          );
          break;

        default:
          print('⚠️ No email notification configured for status: $newStatus');
          emailSent = true; // Don't fail the status update
      }

      if (emailSent) {
        print('✅ Booking status updated to $newStatus and email sent for booking: $bookingId');
      } else {
        print('⚠️ Booking status updated to $newStatus but email failed for booking: $bookingId');
      }

      return true;
    } catch (e) {
      print('❌ Error updating booking status: $e');
      return false;
    }
  }

  /// Cancel a booking and send cancellation email
  static Future<bool> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    return await updateBookingStatus(
      bookingId: bookingId,
      newStatus: 'cancelled',
      cancellationReason: reason,
    );
  }

  /// Complete a booking and send completion email
  static Future<bool> completeBooking({
    required String bookingId,
  }) async {
    return await updateBookingStatus(
      bookingId: bookingId,
      newStatus: 'completed',
    );
  }

  /// Get booking details for a specific booking
  static Future<Map<String, dynamic>?> getBookingDetails(String bookingId) async {
    try {
      final response = await supabase
          .from('bookings')
          .select('*')
          .eq('id', bookingId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ Error getting booking details: $e');
      return null;
    }
  }

  /// Get all bookings for a user
  static Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final response = await supabase
          .from('bookings')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      print('❌ Error getting user bookings: $e');
      return [];
    }
  }

  /// Test the booking status service
  static Future<bool> testBookingStatusService() async {
    try {
      // This is a test method - you can call it to verify the service works
      print('🧪 Testing BookingStatusService...');
      
      // Test getting user bookings
      final user = supabase.auth.currentUser;
      if (user != null) {
        final bookings = await getUserBookings(user.id);
        print('✅ Found ${bookings.length} bookings for user');
        return true;
      } else {
        print('⚠️ No user logged in for testing');
        return false;
      }
    } catch (e) {
      print('❌ Error testing BookingStatusService: $e');
      return false;
    }
  }
}
