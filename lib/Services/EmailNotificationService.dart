import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailNotificationService {
  // Using EmailJS service for sending emails
  // You can replace this with your preferred email service
  static const String _emailJsServiceId = 'YOUR_EMAILJS_SERVICE_ID';
  static const String _emailJsTemplateId = 'YOUR_EMAILJS_TEMPLATE_ID';
  static const String _emailJsUserId = 'YOUR_EMAILJS_USER_ID';
  static const String _emailJsUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  /// Sends booking confirmation email to user
  static Future<bool> sendBookingConfirmationEmail({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
  }) async {
    try {
      final emailData = {
        'service_id': _emailJsServiceId,
        'template_id': _emailJsTemplateId,
        'user_id': _emailJsUserId,
        'template_params': {
          'to_email': userEmail,
          'user_name': userName,
          'from_city': fromCity,
          'to_city': toCity,
          'seats': seats.toString(),
          'total_price': totalPrice.toString(),
          'ride_time': _formatRideTime(rideTime),
          'booking_id': bookingId,
          'booking_date': DateTime.now().toIso8601String().split('T')[0],
        }
      };

      final response = await http.post(
        Uri.parse(_emailJsUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(emailData),
      );

      if (response.statusCode == 200) {
        print('Booking confirmation email sent successfully to $userEmail');
        return true;
      } else {
        print('Failed to send email. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending booking confirmation email: $e');
      return false;
    }
  }

  /// Alternative method using a simple SMTP service (like Resend, SendGrid, etc.)
  static Future<bool> sendBookingConfirmationEmailSMTP({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
  }) async {
    try {
      // Replace with your SMTP service endpoint
      const String smtpServiceUrl = 'YOUR_SMTP_SERVICE_URL';
      const String apiKey = 'YOUR_API_KEY';

      final emailData = {
        'to': userEmail,
        'subject': 'Booking Confirmation - SwiftRide',
        'html': _generateBookingEmailHTML(
          userName: userName,
          fromCity: fromCity,
          toCity: toCity,
          seats: seats,
          totalPrice: totalPrice,
          rideTime: rideTime,
          bookingId: bookingId,
        ),
        'from': 'noreply@swiftride.com',
      };

      final response = await http.post(
        Uri.parse(smtpServiceUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode(emailData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Booking confirmation email sent successfully to $userEmail');
        return true;
      } else {
        print('Failed to send email. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending booking confirmation email: $e');
      return false;
    }
  }

  /// Generate HTML email template for booking confirmation
  static String _generateBookingEmailHTML({
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
  }) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Booking Confirmation - SwiftRide</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #FD5858; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
            .content { background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
            .booking-details { background-color: white; padding: 20px; border-radius: 8px; margin: 20px 0; }
            .detail-row { display: flex; justify-content: space-between; margin: 10px 0; padding: 8px 0; border-bottom: 1px solid #eee; }
            .detail-label { font-weight: bold; color: #555; }
            .detail-value { color: #333; }
            .total-price { font-size: 18px; font-weight: bold; color: #FD5858; }
            .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🚗 SwiftRide</h1>
                <h2>Booking Confirmation</h2>
            </div>
            <div class="content">
                <p>Dear <strong>$userName</strong>,</p>
                <p>Your ride has been successfully booked! Here are your booking details:</p>
                
                <div class="booking-details">
                    <div class="detail-row">
                        <span class="detail-label">Booking ID:</span>
                        <span class="detail-value">$bookingId</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">From:</span>
                        <span class="detail-value">$fromCity</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">To:</span>
                        <span class="detail-value">$toCity</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Seats:</span>
                        <span class="detail-value">$seats</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Ride Time:</span>
                        <span class="detail-value">${_formatRideTime(rideTime)}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Total Price:</span>
                        <span class="detail-value total-price">$totalPrice PKR</span>
                    </div>
                </div>
                
                <p>Thank you for choosing SwiftRide! We'll send you a reminder before your ride.</p>
                <p>If you have any questions, please contact our support team.</p>
            </div>
            <div class="footer">
                <p>© 2024 SwiftRide. All rights reserved.</p>
                <p>This is an automated message. Please do not reply to this email.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Format ride time for display
  static String _formatRideTime(String rideTime) {
    try {
      final dateTime = DateTime.parse(rideTime);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return rideTime;
    }
  }

  /// Simple fallback method using a webhook or custom endpoint
  static Future<bool> sendBookingConfirmationWebhook({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
  }) async {
    try {
      // Replace with your webhook endpoint
      const String webhookUrl = 'YOUR_WEBHOOK_URL';

      final bookingData = {
        'type': 'booking_confirmation',
        'user_email': userEmail,
        'user_name': userName,
        'booking_details': {
          'booking_id': bookingId,
          'from_city': fromCity,
          'to_city': toCity,
          'seats': seats,
          'total_price': totalPrice,
          'ride_time': rideTime,
          'booking_date': DateTime.now().toIso8601String(),
        }
      };

      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(bookingData),
      );

      if (response.statusCode == 200) {
        print('Booking confirmation webhook sent successfully');
        return true;
      } else {
        print('Failed to send webhook. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error sending booking confirmation webhook: $e');
      return false;
    }
  }
}
