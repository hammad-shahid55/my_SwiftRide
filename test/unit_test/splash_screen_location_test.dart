import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Screens/SplashScreen.dart';
import 'package:swift_ride/Screens/EnableLocationScreen.dart';
import 'package:swift_ride/Screens/HomeScreen.dart';
import 'package:swift_ride/Screens/WelcomeScreen.dart';

// Mock classes for testing
class MockGeolocator {
  static bool isLocationServiceEnabled = true;
  static LocationPermission permission = LocationPermission.whileInUse;
  
  static Future<bool> isLocationServiceEnabledMock() async {
    return isLocationServiceEnabled;
  }
  
  static Future<LocationPermission> checkPermissionMock() async {
    return permission;
  }
}

class MockSupabase {
  static User? currentUser;
  
  static User? getCurrentUser() {
    return currentUser;
  }
}

void main() {
  group('SplashScreen Location Check Tests', () {
    testWidgets('should navigate to EnableLocationScreen when location is disabled', (WidgetTester tester) async {
      // Mock location service disabled
      MockGeolocator.isLocationServiceEnabled = false;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Wait for splash animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should navigate to EnableLocationScreen
      expect(find.byType(EnableLocationScreen), findsOneWidget);
    });

    testWidgets('should navigate to EnableLocationScreen when permission is denied', (WidgetTester tester) async {
      // Mock location service enabled but permission denied
      MockGeolocator.isLocationServiceEnabled = true;
      MockGeolocator.permission = LocationPermission.denied;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Wait for splash animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should navigate to EnableLocationScreen
      expect(find.byType(EnableLocationScreen), findsOneWidget);
    });

    testWidgets('should navigate to HomeScreen when logged in and location enabled', (WidgetTester tester) async {
      // Mock location service enabled and permission granted
      MockGeolocator.isLocationServiceEnabled = true;
      MockGeolocator.permission = LocationPermission.whileInUse;
      
      // Mock logged in user
      MockSupabase.currentUser = User(
        id: 'test-user-id',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
      
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Wait for splash animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should navigate to HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should navigate to WelcomeScreen when not logged in and location enabled', (WidgetTester tester) async {
      // Mock location service enabled and permission granted
      MockGeolocator.isLocationServiceEnabled = true;
      MockGeolocator.permission = LocationPermission.whileInUse;
      
      // Mock not logged in user
      MockSupabase.currentUser = null;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Wait for splash animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should navigate to WelcomeScreen
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('should check location before checking login status', (WidgetTester tester) async {
      // Mock logged in user but location disabled
      MockSupabase.currentUser = User(
        id: 'test-user-id',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
      
      // Mock location service disabled
      MockGeolocator.isLocationServiceEnabled = false;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Wait for splash animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should navigate to EnableLocationScreen (not HomeScreen) because location check comes first
      expect(find.byType(EnableLocationScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });
  });
}
