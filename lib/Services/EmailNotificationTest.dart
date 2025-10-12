import 'package:swift_ride/Services/SimpleEmailService.dart';
import 'package:swift_ride/Services/BookingStatusService.dart';
import 'package:swift_ride/Services/AutoCompletionService.dart';

/// Test service for email notifications
class EmailNotificationTest {
  
  /// Test all email notification types
  static Future<void> testAllEmailTypes() async {
    print('🧪 Testing all email notification types...');
    
    // Test booking confirmation
    print('\n📧 Testing Booking Confirmation Email...');
    await SimpleEmailService.sendBookingConfirmation(
      userEmail: 'test@example.com',
      userName: 'Test User',
      fromCity: 'Karachi',
      toCity: 'Lahore',
      seats: 2,
      totalPrice: 5000,
      rideTime: DateTime.now().add(Duration(days: 1)).toIso8601String(),
      bookingId: 'TEST-CONFIRM-${DateTime.now().millisecondsSinceEpoch}',
      fromAddress: 'Karachi Airport Terminal 1',
      toAddress: 'Lahore Railway Station',
    );
    
    // Test booking cancellation
    print('\n📧 Testing Booking Cancellation Email...');
    await SimpleEmailService.sendBookingCancellation(
      userEmail: 'test@example.com',
      userName: 'Test User',
      fromCity: 'Karachi',
      toCity: 'Lahore',
      seats: 2,
      totalPrice: 5000,
      rideTime: DateTime.now().add(Duration(days: 1)).toIso8601String(),
      bookingId: 'TEST-CANCEL-${DateTime.now().millisecondsSinceEpoch}',
      fromAddress: 'Karachi Airport Terminal 1',
      toAddress: 'Lahore Railway Station',
      cancellationReason: 'Test cancellation',
    );
    
    // Test ride completion
    print('\n📧 Testing Ride Completion Email...');
    await SimpleEmailService.sendBookingCompletion(
      userEmail: 'test@example.com',
      userName: 'Test User',
      fromCity: 'Karachi',
      toCity: 'Lahore',
      seats: 2,
      totalPrice: 5000,
      rideTime: DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
      bookingId: 'TEST-COMPLETE-${DateTime.now().millisecondsSinceEpoch}',
      fromAddress: 'Karachi Airport Terminal 1',
      toAddress: 'Lahore Railway Station',
    );
    
    print('\n✅ All email tests completed!');
  }
  
  /// Test auto-completion service
  static Future<void> testAutoCompletion() async {
    print('🧪 Testing Auto-Completion Service...');
    await AutoCompletionService.testAutoCompletionService();
  }
  
  /// Test booking status service
  static Future<void> testBookingStatusService() async {
    print('🧪 Testing Booking Status Service...');
    await BookingStatusService.testBookingStatusService();
  }
  
  /// Run all tests
  static Future<void> runAllTests() async {
    print('🚀 Running all email notification tests...\n');
    
    await testAllEmailTypes();
    print('\n' + '='*50 + '\n');
    
    await testAutoCompletion();
    print('\n' + '='*50 + '\n');
    
    await testBookingStatusService();
    
    print('\n🎉 All tests completed!');
  }
}
