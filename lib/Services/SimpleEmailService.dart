import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swift_ride/Services/EmailConfig.dart';

class SimpleEmailService {
  // Using a simple approach with a webhook or email service
  // This can be easily configured with services like:
  // - Resend (resend.com)
  // - SendGrid
  // - Mailgun
  // - Or your own backend endpoint

  /// Send booking confirmation email using configured email service
  static Future<bool> sendBookingConfirmation({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
    String? fromAddress,
    String? toAddress,
  }) async {
    // Check if email service is configured
    if (!EmailConfig.isEmailConfigured) {
      print('⚠️ Email service not configured. Logging booking details instead.');
      _logBookingDetails(
        userEmail: userEmail,
        userName: userName,
        fromCity: fromCity,
        toCity: toCity,
        seats: seats,
        totalPrice: totalPrice,
        rideTime: rideTime,
        bookingId: bookingId,
      );
      return false;
    }

    try {
      return await _sendWithResend(
        userEmail: userEmail,
        userName: userName,
        fromCity: fromCity,
        toCity: toCity,
        seats: seats,
        totalPrice: totalPrice,
        rideTime: rideTime,
        bookingId: bookingId,
        fromAddress: fromAddress,
        toAddress: toAddress,
      );
    } catch (e) {
      print('❌ Error in SimpleEmailService: $e');
      // Fallback: Just log the booking details
      _logBookingDetails(
        userEmail: userEmail,
        userName: userName,
        fromCity: fromCity,
        toCity: toCity,
        seats: seats,
        totalPrice: totalPrice,
        rideTime: rideTime,
        bookingId: bookingId,
      );
      return false;
    }
  }

  /// Send email using Resend API (free tier available)
  static Future<bool> _sendWithResend({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
    String? fromAddress,
    String? toAddress,
  }) async {
    try {
      final emailData = {
        'from': EmailConfig.resendFromEmail,
        'to': [userEmail],
        'subject': 'Booking Confirmation - ${EmailConfig.appName}',
        'html': _generateEmailHTML(
          userName: userName,
          fromCity: fromCity,
          toCity: toCity,
          seats: seats,
          totalPrice: totalPrice,
          rideTime: rideTime,
          bookingId: bookingId,
          fromAddress: fromAddress,
          toAddress: toAddress,
        ),
      };

      final response = await http.post(
        Uri.parse('https://api.resend.com/emails'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${EmailConfig.resendApiKey}',
        },
        body: json.encode(emailData),
      );

      if (response.statusCode == 200) {
        print('✅ Booking confirmation email sent to $userEmail via Resend');
        return true;
      } else {
        print('❌ Failed to send email via Resend: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending email with Resend: $e');
      return false;
    }
  }


  /// Generate HTML email content
  static String _generateEmailHTML({
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
    String? fromAddress,
    String? toAddress,
  }) {
    final formattedTime = _formatRideTime(rideTime);
    
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Booking Confirmation</title>
        <style>
            body { 
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                line-height: 1.6; 
                color: #333; 
                margin: 0; 
                padding: 0; 
                background-color: #f4f4f4;
            }
            .container { 
                max-width: 600px; 
                margin: 20px auto; 
                background-color: white; 
                border-radius: 10px; 
                overflow: hidden;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            }
            .header { 
                background: linear-gradient(135deg, #FD5858, #ff6b6b); 
                color: white; 
                padding: 30px 20px; 
                text-align: center; 
            }
            .header h1 { margin: 0; font-size: 28px; }
            .header h2 { margin: 10px 0 0 0; font-size: 18px; opacity: 0.9; }
            .content { padding: 30px; }
            .greeting { font-size: 18px; margin-bottom: 20px; }
            .booking-card { 
                background-color: #f8f9fa; 
                border-radius: 8px; 
                padding: 20px; 
                margin: 20px 0; 
                border-left: 4px solid #FD5858;
            }
            .detail-row { 
                display: flex; 
                justify-content: space-between; 
                align-items: center;
                margin: 12px 0; 
                padding: 8px 0; 
                border-bottom: 1px solid #e9ecef; 
            }
            .detail-row:last-child { border-bottom: none; }
            .detail-label { 
                font-weight: 600; 
                color: #495057; 
                flex: 1;
            }
            .detail-value { 
                color: #212529; 
                font-weight: 500;
                text-align: right;
            }
            .total-price { 
                font-size: 20px; 
                font-weight: bold; 
                color: #FD5858; 
            }
            .booking-id { 
                background-color: #e3f2fd; 
                color: #1976d2; 
                padding: 4px 8px; 
                border-radius: 4px; 
                font-family: monospace;
            }
            .message { 
                background-color: #d4edda; 
                border: 1px solid #c3e6cb; 
                color: #155724; 
                padding: 15px; 
                border-radius: 5px; 
                margin: 20px 0;
            }
            .footer { 
                background-color: #f8f9fa; 
                padding: 20px; 
                text-align: center; 
                color: #6c757d; 
                font-size: 14px; 
                border-top: 1px solid #e9ecef;
            }
            .footer p { margin: 5px 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🚗 ${EmailConfig.appName}</h1>
                <h2>Booking Confirmed!</h2>
            </div>
            <div class="content">
                <div class="greeting">
                    Hello <strong>$userName</strong>! 👋
                </div>
                
                <p>Great news! Your ride has been successfully booked. Here are all the details:</p>
                
                <div class="booking-card">
                    <div class="detail-row">
                        <span class="detail-label">Booking ID:</span>
                        <span class="detail-value"><span class="booking-id">$bookingId</span></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">📍 From:</span>
                        <span class="detail-value">$fromCity${fromAddress != null && fromAddress.isNotEmpty ? '<br><small style="color: #666;">$fromAddress</small>' : ''}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">🎯 To:</span>
                        <span class="detail-value">$toCity${toAddress != null && toAddress.isNotEmpty ? '<br><small style="color: #666;">$toAddress</small>' : ''}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">💺 Seats:</span>
                        <span class="detail-value">$seats</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">⏰ Ride Time:</span>
                        <span class="detail-value">$formattedTime</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">💰 Total Price:</span>
                        <span class="detail-value total-price">$totalPrice PKR</span>
                    </div>
                </div>
                
                <div class="message">
                    <strong>📱 What's Next?</strong><br>
                    • We'll send you a reminder before your ride<br>
                    • Keep this email for your records<br>
                    • Contact support if you need any changes
                </div>
                
                <p>Thank you for choosing ${EmailConfig.appName}! We're excited to get you to your destination safely and comfortably.</p>
            </div>
            <div class="footer">
                <p><strong>${EmailConfig.companyName}</strong> - Your reliable ride companion</p>
                <p>© 2024 ${EmailConfig.companyName}. All rights reserved.</p>
                <p><em>This is an automated message. Please do not reply to this email.</em></p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Send cancellation email using Resend
  static Future<bool> _sendCancellationWithResend({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
    String? fromAddress,
    String? toAddress,
    String? cancellationReason,
  }) async {
    try {
      final emailData = {
        'from': EmailConfig.resendFromEmail,
        'to': [userEmail],
        'subject': 'Booking Cancelled - ${EmailConfig.appName}',
        'html': _generateCancellationEmailHTML(
          userName: userName,
          fromCity: fromCity,
          toCity: toCity,
          seats: seats,
          totalPrice: totalPrice,
          rideTime: rideTime,
          bookingId: bookingId,
          fromAddress: fromAddress,
          toAddress: toAddress,
          cancellationReason: cancellationReason,
        ),
      };

      final response = await http.post(
        Uri.parse('https://api.resend.com/emails'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${EmailConfig.resendApiKey}',
        },
        body: json.encode(emailData),
      );

      if (response.statusCode == 200) {
        print('✅ Booking cancellation email sent to $userEmail via Resend');
        return true;
      } else {
        print('❌ Failed to send cancellation email via Resend: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending cancellation email with Resend: $e');
      return false;
    }
  }

  /// Send completion email using Resend
  static Future<bool> _sendCompletionWithResend({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
    String? fromAddress,
    String? toAddress,
  }) async {
    try {
      final emailData = {
        'from': EmailConfig.resendFromEmail,
        'to': [userEmail],
        'subject': 'Ride Completed - ${EmailConfig.appName}',
        'html': _generateCompletionEmailHTML(
          userName: userName,
          fromCity: fromCity,
          toCity: toCity,
          seats: seats,
          totalPrice: totalPrice,
          rideTime: rideTime,
          bookingId: bookingId,
          fromAddress: fromAddress,
          toAddress: toAddress,
        ),
      };

      final response = await http.post(
        Uri.parse('https://api.resend.com/emails'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${EmailConfig.resendApiKey}',
        },
        body: json.encode(emailData),
      );

      if (response.statusCode == 200) {
        print('✅ Ride completion email sent to $userEmail via Resend');
        return true;
      } else {
        print('❌ Failed to send completion email via Resend: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending completion email with Resend: $e');
      return false;
    }
  }

  /// Generate cancellation email HTML
  static String _generateCancellationEmailHTML({
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
    String? fromAddress,
    String? toAddress,
    String? cancellationReason,
  }) {
    final formattedTime = _formatRideTime(rideTime);
    
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Booking Cancelled</title>
        <style>
            body { 
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                line-height: 1.6; 
                color: #333; 
                margin: 0; 
                padding: 0; 
                background-color: #f4f4f4;
            }
            .container { 
                max-width: 600px; 
                margin: 20px auto; 
                background-color: white; 
                border-radius: 10px; 
                overflow: hidden;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            }
            .header { 
                background: linear-gradient(135deg, #dc3545, #e74c3c); 
                color: white; 
                padding: 30px 20px; 
                text-align: center; 
            }
            .header h1 { margin: 0; font-size: 28px; }
            .header h2 { margin: 10px 0 0 0; font-size: 18px; opacity: 0.9; }
            .content { padding: 30px; }
            .greeting { font-size: 18px; margin-bottom: 20px; }
            .booking-card { 
                background-color: #f8f9fa; 
                border-radius: 8px; 
                padding: 20px; 
                margin: 20px 0; 
                border-left: 4px solid #dc3545;
            }
            .detail-row { 
                display: flex; 
                justify-content: space-between; 
                align-items: center;
                margin: 12px 0; 
                padding: 8px 0; 
                border-bottom: 1px solid #e9ecef; 
            }
            .detail-row:last-child { border-bottom: none; }
            .detail-label { 
                font-weight: 600; 
                color: #495057; 
                flex: 1;
            }
            .detail-value { 
                color: #212529; 
                font-weight: 500;
                text-align: right;
            }
            .total-price { 
                font-size: 20px; 
                font-weight: bold; 
                color: #dc3545; 
            }
            .booking-id { 
                background-color: #f8d7da; 
                color: #721c24; 
                padding: 4px 8px; 
                border-radius: 4px; 
                font-family: monospace;
            }
            .message { 
                background-color: #d1ecf1; 
                border: 1px solid #bee5eb; 
                color: #0c5460; 
                padding: 15px; 
                border-radius: 5px; 
                margin: 20px 0;
            }
            .footer { 
                background-color: #f8f9fa; 
                padding: 20px; 
                text-align: center; 
                color: #6c757d; 
                font-size: 14px; 
                border-top: 1px solid #e9ecef;
            }
            .footer p { margin: 5px 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🚗 ${EmailConfig.appName}</h1>
                <h2>Booking Cancelled</h2>
            </div>
            <div class="content">
                <div class="greeting">
                    Hello <strong>$userName</strong>! 👋
                </div>
                
                <p>We're sorry to inform you that your booking has been cancelled. Here are the details:</p>
                
                <div class="booking-card">
                    <div class="detail-row">
                        <span class="detail-label">Booking ID:</span>
                        <span class="detail-value"><span class="booking-id">$bookingId</span></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">📍 From:</span>
                        <span class="detail-value">$fromCity${fromAddress != null && fromAddress.isNotEmpty ? '<br><small style="color: #666;">$fromAddress</small>' : ''}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">🎯 To:</span>
                        <span class="detail-value">$toCity${toAddress != null && toAddress.isNotEmpty ? '<br><small style="color: #666;">$toAddress</small>' : ''}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">💺 Seats:</span>
                        <span class="detail-value">$seats</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">⏰ Ride Time:</span>
                        <span class="detail-value">$formattedTime</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">💰 Total Price:</span>
                        <span class="detail-value total-price">$totalPrice PKR</span>
                    </div>
                </div>
                
                <div class="message">
                    <strong>📱 What's Next?</strong><br>
                    • Your payment will be refunded within 3-5 business days<br>
                    • You can book another ride anytime<br>
                    • Contact support if you have any questions
                </div>
                
                <p>We apologize for any inconvenience. Thank you for choosing ${EmailConfig.appName}!</p>
            </div>
            <div class="footer">
                <p><strong>${EmailConfig.companyName}</strong> - Your reliable ride companion</p>
                <p>© 2024 ${EmailConfig.companyName}. All rights reserved.</p>
                <p><em>This is an automated message. Please do not reply to this email.</em></p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Generate completion email HTML
  static String _generateCompletionEmailHTML({
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
    String? fromAddress,
    String? toAddress,
  }) {
    final formattedTime = _formatRideTime(rideTime);
    
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Ride Completed</title>
        <style>
            body { 
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                line-height: 1.6; 
                color: #333; 
                margin: 0; 
                padding: 0; 
                background-color: #f4f4f4;
            }
            .container { 
                max-width: 600px; 
                margin: 20px auto; 
                background-color: white; 
                border-radius: 10px; 
                overflow: hidden;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            }
            .header { 
                background: linear-gradient(135deg, #28a745, #20c997); 
                color: white; 
                padding: 30px 20px; 
                text-align: center; 
            }
            .header h1 { margin: 0; font-size: 28px; }
            .header h2 { margin: 10px 0 0 0; font-size: 18px; opacity: 0.9; }
            .content { padding: 30px; }
            .greeting { font-size: 18px; margin-bottom: 20px; }
            .booking-card { 
                background-color: #f8f9fa; 
                border-radius: 8px; 
                padding: 20px; 
                margin: 20px 0; 
                border-left: 4px solid #28a745;
            }
            .detail-row { 
                display: flex; 
                justify-content: space-between; 
                align-items: center;
                margin: 12px 0; 
                padding: 8px 0; 
                border-bottom: 1px solid #e9ecef; 
            }
            .detail-row:last-child { border-bottom: none; }
            .detail-label { 
                font-weight: 600; 
                color: #495057; 
                flex: 1;
            }
            .detail-value { 
                color: #212529; 
                font-weight: 500;
                text-align: right;
            }
            .total-price { 
                font-size: 20px; 
                font-weight: bold; 
                color: #28a745; 
            }
            .booking-id { 
                background-color: #d4edda; 
                color: #155724; 
                padding: 4px 8px; 
                border-radius: 4px; 
                font-family: monospace;
            }
            .message { 
                background-color: #d1ecf1; 
                border: 1px solid #bee5eb; 
                color: #0c5460; 
                padding: 15px; 
                border-radius: 5px; 
                margin: 20px 0;
            }
            .footer { 
                background-color: #f8f9fa; 
                padding: 20px; 
                text-align: center; 
                color: #6c757d; 
                font-size: 14px; 
                border-top: 1px solid #e9ecef;
            }
            .footer p { margin: 5px 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🚗 ${EmailConfig.appName}</h1>
                <h2>Ride Completed! 🎉</h2>
            </div>
            <div class="content">
                <div class="greeting">
                    Hello <strong>$userName</strong>! 👋
                </div>
                
                <p>Great news! Your ride has been completed successfully. Here are the details:</p>
                
                <div class="booking-card">
                    <div class="detail-row">
                        <span class="detail-label">Booking ID:</span>
                        <span class="detail-value"><span class="booking-id">$bookingId</span></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">📍 From:</span>
                        <span class="detail-value">$fromCity${fromAddress != null && fromAddress.isNotEmpty ? '<br><small style="color: #666;">$fromAddress</small>' : ''}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">🎯 To:</span>
                        <span class="detail-value">$toCity${toAddress != null && toAddress.isNotEmpty ? '<br><small style="color: #666;">$toAddress</small>' : ''}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">💺 Seats:</span>
                        <span class="detail-value">$seats</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">⏰ Ride Time:</span>
                        <span class="detail-value">$formattedTime</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">💰 Total Price:</span>
                        <span class="detail-value total-price">$totalPrice PKR</span>
                    </div>
                </div>
                
                <div class="message">
                    <strong>📱 Thank You!</strong><br>
                    • We hope you had a comfortable and safe journey<br>
                    • Please rate your experience in the app<br>
                    • Book your next ride anytime
                </div>
                
                <p>Thank you for choosing ${EmailConfig.appName}! We look forward to serving you again.</p>
            </div>
            <div class="footer">
                <p><strong>${EmailConfig.companyName}</strong> - Your reliable ride companion</p>
                <p>© 2024 ${EmailConfig.companyName}. All rights reserved.</p>
                <p><em>This is an automated message. Please do not reply to this email.</em></p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Format ride time for better display
  static String _formatRideTime(String rideTime) {
    try {
      final dateTime = DateTime.parse(rideTime);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      
      final day = dateTime.day;
      final month = months[dateTime.month - 1];
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      
      return '$day $month $year at $hour:$minute';
    } catch (e) {
      return rideTime;
    }
  }

  /// Fallback: Log booking details (for development/testing)
  static void _logBookingDetails({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
    String? fromAddress,
    String? toAddress,
  }) {
    print('📧 BOOKING CONFIRMATION EMAIL (Fallback Log)');
    print('==========================================');
    print('To: $userEmail');
    print('Name: $userName');
    print('From: $fromCity${fromAddress != null ? ' - $fromAddress' : ''}');
    print('To: $toCity${toAddress != null ? ' - $toAddress' : ''}');
    print('Seats: $seats');
    print('Total Price: $totalPrice PKR');
    print('Ride Time: ${_formatRideTime(rideTime)}');
    print('Booking ID: $bookingId');
    print('==========================================');
  }

  /// Fallback: Log cancellation details
  static void _logCancellationDetails({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
    String? fromAddress,
    String? toAddress,
    String? cancellationReason,
  }) {
    print('📧 BOOKING CANCELLATION EMAIL (Fallback Log)');
    print('==========================================');
    print('To: $userEmail');
    print('Name: $userName');
    print('From: $fromCity${fromAddress != null ? ' - $fromAddress' : ''}');
    print('To: $toCity${toAddress != null ? ' - $toAddress' : ''}');
    print('Seats: $seats');
    print('Total Price: $totalPrice PKR');
    print('Ride Time: ${_formatRideTime(rideTime)}');
    print('Booking ID: $bookingId');
    if (cancellationReason != null) {
      print('Cancellation Reason: $cancellationReason');
    }
    print('==========================================');
  }

  /// Fallback: Log completion details
  static void _logCompletionDetails({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
    String? fromAddress,
    String? toAddress,
  }) {
    print('📧 RIDE COMPLETION EMAIL (Fallback Log)');
    print('==========================================');
    print('To: $userEmail');
    print('Name: $userName');
    print('From: $fromCity${fromAddress != null ? ' - $fromAddress' : ''}');
    print('To: $toCity${toAddress != null ? ' - $toAddress' : ''}');
    print('Seats: $seats');
    print('Total Price: $totalPrice PKR');
    print('Ride Time: ${_formatRideTime(rideTime)}');
    print('Booking ID: $bookingId');
    print('==========================================');
  }

  /// Send booking cancellation email
  static Future<bool> sendBookingCancellation({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
    String? fromAddress,
    String? toAddress,
    String? cancellationReason,
  }) async {
    // Check if email service is configured
    if (!EmailConfig.isEmailConfigured) {
      print('⚠️ Email service not configured. Logging cancellation details instead.');
      _logCancellationDetails(
        userEmail: userEmail,
        userName: userName,
        fromCity: fromCity,
        toCity: toCity,
        seats: seats,
        totalPrice: totalPrice,
        rideTime: rideTime,
        bookingId: bookingId,
        fromAddress: fromAddress,
        toAddress: toAddress,
        cancellationReason: cancellationReason,
      );
      return false;
    }

    try {
      return await _sendCancellationWithResend(
        userEmail: userEmail,
        userName: userName,
        fromCity: fromCity,
        toCity: toCity,
        seats: seats,
        totalPrice: totalPrice,
        rideTime: rideTime,
        bookingId: bookingId,
        fromAddress: fromAddress,
        toAddress: toAddress,
        cancellationReason: cancellationReason,
      );
    } catch (e) {
      print('❌ Error sending cancellation email: $e');
      return false;
    }
  }

  /// Send booking completion email
  static Future<bool> sendBookingCompletion({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
    String? fromAddress,
    String? toAddress,
  }) async {
    // Check if email service is configured
    if (!EmailConfig.isEmailConfigured) {
      print('⚠️ Email service not configured. Logging completion details instead.');
      _logCompletionDetails(
        userEmail: userEmail,
        userName: userName,
        fromCity: fromCity,
        toCity: toCity,
        seats: seats,
        totalPrice: totalPrice,
        rideTime: rideTime,
        bookingId: bookingId,
        fromAddress: fromAddress,
        toAddress: toAddress,
      );
      return false;
    }

    try {
      return await _sendCompletionWithResend(
        userEmail: userEmail,
        userName: userName,
        fromCity: fromCity,
        toCity: toCity,
        seats: seats,
        totalPrice: totalPrice,
        rideTime: rideTime,
        bookingId: bookingId,
        fromAddress: fromAddress,
        toAddress: toAddress,
      );
    } catch (e) {
      print('❌ Error sending completion email: $e');
      return false;
    }
  }

  /// Test email functionality
  static Future<bool> testEmailService() async {
    return await sendBookingConfirmation(
      userEmail: 'test@example.com',
      userName: 'Test User',
      fromCity: 'Karachi',
      toCity: 'Lahore',
      seats: 2,
      totalPrice: 5000,
      rideTime: DateTime.now().add(Duration(days: 1)).toIso8601String(),
      bookingId: 'TEST-${DateTime.now().millisecondsSinceEpoch}',
      fromAddress: 'Karachi Airport Terminal 1',
      toAddress: 'Lahore Railway Station',
    );
  }
}
