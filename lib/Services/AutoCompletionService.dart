import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Services/BookingStatusService.dart';

/// Service to automatically mark rides as completed when ride time passes
class AutoCompletionService {
  static final supabase = Supabase.instance.client;

  /// Check and auto-complete rides that have passed their ride time
  static Future<void> checkAndAutoCompleteRides() async {
    try {
      print('🔄 Checking for rides to auto-complete...');
      
      final now = DateTime.now();
      
      // Get all booked rides that should be completed
      final response = await supabase
          .from('bookings')
          .select('*')
          .eq('status', 'booked')
          .lt('ride_time', now.toIso8601String());

      final ridesToComplete = response;
      
      if (ridesToComplete.isEmpty) {
        print('✅ No rides to auto-complete');
        return;
      }

      print('📋 Found ${ridesToComplete.length} rides to auto-complete');

      // Process each ride
      for (final booking in ridesToComplete) {
        final bookingId = booking['id']?.toString();
        if (bookingId != null) {
          try {
            print('🚗 Auto-completing ride: $bookingId');
            
            // Use BookingStatusService to complete and send email
            final success = await BookingStatusService.completeBooking(
              bookingId: bookingId,
            );

            if (success) {
              print('✅ Successfully auto-completed ride: $bookingId');
            } else {
              print('❌ Failed to auto-complete ride: $bookingId');
            }
          } catch (e) {
            print('❌ Error auto-completing ride $bookingId: $e');
          }
        }
      }

      print('🎉 Auto-completion check completed');
    } catch (e) {
      print('❌ Error in auto-completion service: $e');
    }
  }

  /// Check for rides that should be completed for a specific user
  static Future<void> checkUserRidesForCompletion(String userId) async {
    try {
      final now = DateTime.now();
      
      // Get user's booked rides that should be completed
      final response = await supabase
          .from('bookings')
          .select('*')
          .eq('user_id', userId)
          .eq('status', 'booked')
          .lt('ride_time', now.toIso8601String());

      final userRidesToComplete = response;
      
      if (userRidesToComplete.isEmpty) {
        return;
      }

      print('👤 Found ${userRidesToComplete.length} rides to auto-complete for user: $userId');

      // Process each ride
      for (final booking in userRidesToComplete) {
        final bookingId = booking['id']?.toString();
        if (bookingId != null) {
          try {
            await BookingStatusService.completeBooking(
              bookingId: bookingId,
            );
            print('✅ Auto-completed user ride: $bookingId');
          } catch (e) {
            print('❌ Error auto-completing user ride $bookingId: $e');
          }
        }
      }
    } catch (e) {
      print('❌ Error checking user rides for completion: $e');
    }
  }

  /// Get rides that are due for completion (for display purposes)
  static Future<List<Map<String, dynamic>>> getRidesDueForCompletion() async {
    try {
      final now = DateTime.now();
      
      final response = await supabase
          .from('bookings')
          .select('*')
          .eq('status', 'booked')
          .lt('ride_time', now.toIso8601String());

      return response;
    } catch (e) {
      print('❌ Error getting rides due for completion: $e');
      return [];
    }
  }

  /// Get user's rides that are due for completion
  static Future<List<Map<String, dynamic>>> getUserRidesDueForCompletion(String userId) async {
    try {
      final now = DateTime.now();
      
      final response = await supabase
          .from('bookings')
          .select('*')
          .eq('user_id', userId)
          .eq('status', 'booked')
          .lt('ride_time', now.toIso8601String());

      return response;
    } catch (e) {
      print('❌ Error getting user rides due for completion: $e');
      return [];
    }
  }

  /// Test the auto-completion service
  static Future<bool> testAutoCompletionService() async {
    try {
      print('🧪 Testing AutoCompletionService...');
      
      final ridesDue = await getRidesDueForCompletion();
      print('📊 Found ${ridesDue.length} rides due for completion');
      
      // Test with a small sample (don't actually complete them)
      for (final ride in ridesDue.take(3)) {
        final rideTime = ride['ride_time'] as String?;
        final bookingId = ride['id']?.toString();
        print('🚗 Ride $bookingId was scheduled for: $rideTime');
      }
      
      return true;
    } catch (e) {
      print('❌ Error testing AutoCompletionService: $e');
      return false;
    }
  }
}
