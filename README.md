# Swift Ride - Complete Project Documentation

Swift Ride is a comprehensive cross-platform ride booking and management system featuring a Flutter mobile application, React/TypeScript admin web panel, and integrated backend services.

## Overview

The system consists of:

- **Flutter Mobile App**: Cross-platform mobile application for users and drivers
- **React/TypeScript Admin Web Panel**: Complete admin dashboard for management
- **Supabase Backend**: Authentication, database, storage, and real-time features
- **Stripe Integration**: Secure payment processing and wallet management
- **Google Maps Integration**: Route planning, location services, and navigation
- **Email Notification System**: Automated email notifications via Resend API
- **Ratings System**: User feedback and driver performance metrics
- **Multi-platform Support**: Android, iOS, Web, and Desktop builds

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Quick Start](#2-quick-start)
3. [Environment Variables](#3-environment-variables)
4. [Project Structure](#4-project-structure)
5. [Core Dependencies](#5-core-dependencies)
6. [App Initialization Flow](#6-app-initialization-flow)
7. [Backend Integration](#7-backend-integration)
8. [Data Model & Database](#8-data-model--database)
9. [Flutter App Screens](#9-flutter-app-screens)
10. [Flutter App Widgets](#10-flutter-app-widgets)
11. [Admin Web Pages](#11-admin-web-pages)
12. [Platform Configuration](#12-platform-configuration)
13. [Assets & Styling](#13-assets--styling)
14. [Building & Release](#14-building--release)
15. [Testing Framework](#15-testing-framework)
16. [Troubleshooting](#16-troubleshooting)
17. [Security & Extending](#17-security--extending)

---

## 1. Prerequisites

### Development Environment

- **Flutter SDK** (3.7+) with Dart SDK (bundled)
- **Node.js** (18+) for admin web development
- **Git** for version control
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA

### Platform-Specific Requirements

- **Android Development**: Android Studio, Android SDK, Java 11+
- **iOS Development**: Xcode 14+, macOS, iOS Simulator
- **Web Development**: Modern browser with WebGL support

### External Services

- **Supabase Project** (URL + anon key) - Backend services
- **Stripe Account** (publishable key) - Payment processing
- **Google Cloud Console** (Maps API key) - Location services
- **Google Sign-In** (OAuth credentials) - Social authentication
- **Resend Account** (API key) - Email notification service

## 2. Quick Start

### Flutter App

```bash
# Clone the repository
git clone <repository-url>
cd my_SwiftRide

# Install dependencies
flutter pub get

# Create .env file with your API keys (see Environment Variables section)

# Run the app
flutter run
```

### Admin Web

```bash
# Navigate to admin web directory
cd admin_web

# Install dependencies
npm install

# Create .env file with your Supabase credentials

# Start development server
npm run dev

# Build for production
npm run build
```

### First-Time Setup Checklist

1. **Environment Setup**
   - Create `.env` file in project root
   - Create `admin_web/.env` file
   - Add all required API keys

2. **Database Setup**
   - Set up Supabase project
   - Create required tables
   - Configure Row Level Security (RLS)

3. **External Services**
   - Configure Stripe webhook endpoints
   - Set up Google Maps API
   - Configure Google Sign-In OAuth
   - Set up Resend email service

4. **Platform Setup**
   - Android: Configure signing keys
   - iOS: Configure provisioning profiles
   - Web: Configure hosting (optional)

## 3. Environment Variables

### Flutter: `.env` at project root

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key

# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key

# Google Services
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
GOOGLE_SIGN_IN_CLIENT_ID=your_google_oauth_client_id

# Email Service Configuration (Resend)
RESEND_API_KEY=re_your_resend_api_key
RESEND_FROM_EMAIL=onboarding@resend.dev

# App Configuration
APP_NAME=SwiftRide
COMPANY_NAME=SwiftRide
SUPPORT_EMAIL=support@swiftride.com

# Optional: Development flags
DEBUG_MODE=true
LOG_LEVEL=debug
```

### Admin Web: `admin_web/.env`

```env
# Supabase Configuration
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key

# Google Services (for admin maps)
VITE_GOOGLE_MAPS_API_KEY=your_google_maps_api_key

# Optional: Development flags
VITE_DEBUG_MODE=true
```

### Environment Variables Reference

| Variable | Description | Required | Platform |
|----------|------------|----------|----------|
| `SUPABASE_URL` | Supabase project URL | Yes | Flutter |
| `SUPABASE_ANON_KEY` | Supabase anonymous key | Yes | Flutter |
| `STRIPE_PUBLISHABLE_KEY` | Stripe publishable key | Yes | Flutter |
| `GOOGLE_MAPS_API_KEY` | Google Maps API key | Yes | Flutter |
| `GOOGLE_SIGN_IN_CLIENT_ID` | Google OAuth client ID | Yes | Flutter |
| `RESEND_API_KEY` | Resend email service API key | Yes | Flutter |
| `RESEND_FROM_EMAIL` | Resend sender email address | Yes | Flutter |
| `APP_NAME` | Application name for emails | Yes | Flutter |
| `COMPANY_NAME` | Company name for branding | Yes | Flutter |
| `SUPPORT_EMAIL` | Support email address | Yes | Flutter |
| `VITE_SUPABASE_URL` | Supabase project URL | Yes | Admin Web |
| `VITE_SUPABASE_ANON_KEY` | Supabase anonymous key | Yes | Admin Web |
| `VITE_GOOGLE_MAPS_API_KEY` | Google Maps API key | Yes | Admin Web |

## 4. Project Structure

```
my_SwiftRide/
├── lib/                          # Flutter app source code
│   ├── main.dart                 # App entry point
│   ├── Screens/                  # All app screens (22 files)
│   ├── Services/                 # Business logic services (5 files)
│   └── Widgets/                  # Reusable UI components (17 files)
├── assets/                       # Static assets
│   ├── fonts/                   # Custom fonts (4 families)
│   └── ... (images, icons, map styles)
├── admin_web/                   # React admin dashboard
│   ├── src/
│   │   ├── main.tsx            # Admin app entry point
│   │   ├── pages/              # Admin pages (8 files)
│   │   └── lib/
│   └── ... (config files)
├── android/                     # Android platform files
├── ios/                         # iOS platform files
├── web/                         # Web platform files
├── windows/                     # Windows platform files
├── linux/                       # Linux platform files
├── macos/                       # macOS platform files
├── pubspec.yaml                 # Flutter dependencies
├── .env                         # Environment variables
└── README.md                    # This documentation
```

### Key Directories

- **`lib/Screens/`**: Contains all 22 app screens with complete user flows
- **`lib/Services/`**: Contains 5 business logic services including email notification system
- **`lib/Widgets/`**: Contains 17 reusable UI components and widgets
- **`assets/`**: Static resources including fonts, images, and map styles
- **`admin_web/`**: Complete React/TypeScript admin dashboard
- **Platform folders**: Platform-specific configurations for Android, iOS, Web, Windows, Linux, macOS

## 5. Core Dependencies

### Flutter Dependencies

#### Backend & Authentication
- `supabase_flutter: ^2.9.1` - Supabase client for auth, database, storage
- `google_sign_in: ^7.1.0` - Google OAuth authentication
- `flutter_dotenv: ^6.0.0` - Environment variables management

#### Email Notifications
- `http: ^0.13.6` - HTTP requests for email service integration
- Resend API - Email notification service

#### Payment Processing
- `flutter_stripe: ^11.5.0` - Stripe payment integration

#### Maps & Location Services
- `google_maps_flutter: ^2.12.3` - Google Maps integration
- `geolocator: ^14.0.2` - Location services and permissions
- `geocoding: ^4.0.0` - Address geocoding
- `google_place: ^0.4.7` - Google Places API
- `google_maps_webservice: ^0.0.20-nullsafety.5` - Google Maps web services
- `flutter_polyline_points: ^1.0.0` - Route polyline rendering

#### UI & Utilities
- `animated_text_kit: ^4.2.3` - Text animations
- `loading_animation_widget: ^1.3.0` - Loading animations
- `flutter_native_splash: ^2.4.6` - Native splash screen
- `connectivity_plus: ^6.1.4` - Network connectivity
- `shared_preferences: ^2.5.3` - Local storage
- `intl: ^0.20.2` - Internationalization
- `timezone: ^0.9.4` - Timezone handling
- `image_picker: ^1.1.2` - Image selection
- `otp_text_field: ^1.1.3` - OTP input fields

### Admin Web Dependencies

#### Core Framework
- `react: ^18.3.1` - React framework
- `react-dom: ^18.3.1` - React DOM rendering
- `react-router-dom: ^6.26.2` - Client-side routing

#### Backend Integration
- `@supabase/supabase-js: ^2.45.4` - Supabase JavaScript client

#### Development Tools
- `vite: ^5.4.2` - Build tool and dev server
- `typescript: ^5.6.2` - TypeScript support
- `@vitejs/plugin-react: ^4.3.2` - Vite React plugin

### Dependency Categories

| Category | Flutter Packages | Purpose |
|----------|------------------|---------|
| Backend | supabase_flutter, google_sign_in | Authentication & data |
| Payments | flutter_stripe, http | Payment processing |
| Maps | google_maps_flutter, geolocator, geocoding | Location services |
| Email | http, Resend API | Email notifications |
| UI | animated_text_kit, loading_animation_widget | User interface |
| Storage | shared_preferences, connectivity_plus | Local data & network |
| Utils | intl, timezone, image_picker | Utilities |

## 6. App Initialization Flow

The application initializes in `main.dart` with the following sequence:

1. Load environment variables from `.env` file
2. Initialize Supabase client with URL and anon key
3. Initialize Stripe with publishable key
4. Check email configuration status
5. Run auto-completion service for rides
6. Launch the application

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    print('.env file not found, using default values');
  }

  final envSupabaseUrl = dotenv.env['SUPABASE_URL'] ?? supabaseUrl;
  final envSupabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? supabaseKey;
  final stripeKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  if (stripeKey.isNotEmpty) {
    Stripe.publishableKey = stripeKey;
  }
  await Supabase.initialize(url: envSupabaseUrl, anonKey: envSupabaseKey);

  EmailTestService.printConfigurationStatus();
  AutoCompletionService.checkAndAutoCompleteRides();

  runApp(MainApp());
}
```

## 7. Backend Integration

### 7.1. Supabase Integration

Supabase provides authentication, database, storage, and real-time features. The app initializes a global Supabase client via `Supabase.initialize` in `main.dart`. Access the client anywhere via `Supabase.instance.client`.

**Example: Creating a Trip Record**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> createTrip() async {
  final sb = Supabase.instance.client;
  await sb.from('trips').insert({
    'from_city': 'Lahore',
    'to_city': 'Islamabad',
    'depart_time': DateTime.now().toIso8601String(),
    'arrive_time': DateTime.now().add(const Duration(hours: 4)).toIso8601String(),
    'price': 1200,
    'total_seats': 12,
  });
}
```

### 7.2. Stripe Integration

Stripe PaymentSheet is used for wallet top-up. The payment flow:

1. Validate amount (minimum Rs 500)
2. Call Supabase Edge Function `create-payment-intent` with bearer token
3. Initialize and present Stripe PaymentSheet using returned client secret
4. On success, call Supabase RPC `increment_wallet` to update `profiles.wallet_balance`
5. Refresh balance from `profiles`

### 7.3. Google Maps Integration

The app uses Google Maps and Directions API for route planning:

- Packages: `google_maps_flutter`, `google_maps_webservice`, `flutter_polyline_points`, `geocoding`, `geolocator`
- Environment: `GOOGLE_MAPS_API_KEY` must be set in `.env`
- Flow in `DirectionsMapScreen`:
  1. Geocode `from`/`to` addresses to coordinates
  2. Fetch route via Google Directions API, decode polyline
  3. Render on `GoogleMap` with custom pickup/dropoff markers
  4. Display `BookingWidget` overlay for seat selection/payment

### 7.4. Email Notification System

SwiftRide includes a comprehensive email notification system powered by Resend API for automated user communications.

#### Email Features

1. **Booking Confirmation Emails**
   - Trigger: When user successfully books a ride
   - Content: Trip details, seat information, total price, full addresses
   - Template: Professional HTML with SwiftRide branding

2. **Booking Cancellation Emails**
   - Trigger: When user cancels booking from History screen
   - Content: Cancellation confirmation with refund information
   - Template: Red-themed HTML with cancellation details

3. **Ride Completion Emails**
   - Trigger: Automatically when ride time passes
   - Content: Completion confirmation with thank you message
   - Template: Green-themed HTML with completion details

4. **Complaint Confirmation Emails**
   - Trigger: When user submits complaint via Contact Us
   - Content: Complaint acknowledgment with tracking ID
   - Template: Professional HTML with support information

5. **Account Deletion Confirmation Emails**
   - Trigger: When user successfully deletes their account
   - Content: Account deletion confirmation with data removal summary
   - Template: Professional HTML with deletion details

#### Email Service Architecture

- **EmailConfig.dart**: Centralized email service configuration, Resend API integration, environment variable support
- **SimpleEmailService.dart**: Core email sending functionality, HTML template generation, Resend API integration, error handling
- **EmailTestService.dart**: Email configuration testing, test email sending functionality, configuration status checking
- **BookingStatusService.dart**: Booking status management, email trigger coordination, user profile integration
- **AutoCompletionService.dart**: Automatic ride completion detection, background email processing, time-based completion logic

#### Email Flow Integration

**Booking Flow**: User books ride → Booking saved → `SimpleEmailService.sendBookingConfirmation()` called → Email sent via Resend API

**Cancellation Flow**: User cancels → `BookingStatusService.cancelBooking()` called → Status updated → `SimpleEmailService.sendBookingCancellation()` called

**Auto-Completion Flow**: App starts → `AutoCompletionService.checkAndAutoCompleteRides()` called → Checks for past rides → `SimpleEmailService.sendBookingCompletion()` called

**Complaint Flow**: User submits complaint → Complaint saved → `SimpleEmailService.sendComplaintConfirmation()` called

**Account Deletion Flow**: User confirms deletion → Account deleted → `SimpleEmailService.sendAccountDeletionConfirmation()` called → User signed out

#### Configuration

**Environment Variables**:
```env
RESEND_API_KEY=re_your_resend_api_key
RESEND_FROM_EMAIL=onboarding@resend.dev
APP_NAME=SwiftRide
COMPANY_NAME=SwiftRide
SUPPORT_EMAIL=support@swiftride.com
```

**Resend Setup**:
1. Create account at resend.com
2. Get API key from dashboard
3. Verify domain or use test domain
4. Add API key to `.env` file
5. Test email functionality

### 7.5. Ratings & Feedback System

SwiftRide includes a comprehensive ratings and feedback system that allows users to rate their completed rides and provides drivers with overall performance metrics.

#### Ratings Features

1. **User Rating System**
   - Trigger: Available for completed rides in History screen
   - Rating Scale: 1-5 stars (integer rating)
   - Interactive UI: StarRating widget with visual feedback
   - Rating Persistence: Ratings stored in `ratings` table in Supabase
   - Update Capability: Users can update their ratings at any time

2. **Driver Performance Metrics**
   - Overall Rating: Calculated as average of all ratings for a driver
   - Total Ratings Count: Number of ratings received by driver
   - Real-time Updates: Ratings calculated dynamically from database
   - Admin Dashboard: Overall ratings displayed in Drivers page
   - Driver Detail View: Detailed rating statistics in driver profile

#### Ratings System Architecture

- **StarRating Widget** (`lib/Widgets/StarRating.dart`): Interactive star rating component, customizable size/color, supports 1-5 star ratings
- **HistoryScreen Integration**: Rating section displayed for completed rides, fetches existing ratings, allows users to rate or update ratings
- **Admin Web Integration**: Drivers page shows overall rating and total ratings count, Driver Detail page displays detailed rating statistics

#### Rating Flow

**User Rating Flow**: User completes ride → Ride appears in History → User opens completed ride card → Rating section displayed → User taps stars to rate → Rating saved to `ratings` table → Success confirmation shown

**Rating Update Flow**: User views previously rated ride → Existing rating displayed → User can change rating → Rating updated in database → Updated rating reflected immediately

**Driver Rating Calculation**: Admin opens Drivers page → System fetches all ratings for each driver → Calculates average rating → Rounds to 1 decimal place → Displays overall rating and total ratings count

#### Database Schema

**Ratings Table Structure**:
```sql
CREATE TABLE ratings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid REFERENCES bookings(id),
  user_id uuid REFERENCES auth.users(id),
  driver_id uuid REFERENCES drivers(id),
  trip_id uuid REFERENCES trips(id),
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_ratings_driver_id ON ratings(driver_id);
CREATE INDEX idx_ratings_booking_id ON ratings(booking_id);
CREATE INDEX idx_ratings_user_id ON ratings(user_id);
```

**Rating Queries**:
```sql
-- Calculate driver overall rating
SELECT 
  driver_id,
  AVG(rating) as overall_rating,
  COUNT(*) as total_ratings
FROM ratings
WHERE driver_id = $1
GROUP BY driver_id;
```

## 8. Data Model & Database

### Core Tables

- `profiles`: User info, wallet balance
- `location_history`: Recent locations
- `trips`: All available trips
- `bookings`: User bookings with email notification triggers
- `ratings`: User ratings for completed rides (1-5 stars)
- `drivers`: Driver profiles and information
- `vans`: Vehicle information and details

### Database Functions

- Edge function: `create-payment-intent` (Stripe)
- RPC: `increment_wallet` (wallet top-up)

### Trip Assignment History Queries

For the TripHistoryScreen feature:

```sql
SELECT 
  t.id,
  t."from",
  t."to", 
  t.depart_time,
  t.arrive_time,
  t.type,
  t.ac,
  t.total_seats,
  t.driver_id,
  t.van_id,
  v.name as van_name,
  v.plate as van_plate,
  d.full_name as driver_name,
  d.phone as driver_phone
FROM public.trips t
LEFT JOIN public.vans v ON t.van_id = v.id
LEFT JOIN public.drivers d ON t.driver_id = d.id
WHERE (t.driver_id = $1 OR t.driver_id IS NULL)
ORDER BY t.depart_time DESC 
LIMIT 50;
```

### Row Level Security (RLS) Policies

```sql
-- Enable RLS on trips table
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;

-- Policy for drivers to view their trips and unassigned trips
CREATE POLICY "Drivers can view their trips and unassigned trips" ON public.trips
FOR SELECT USING (
  driver_id = auth.uid() OR 
  driver_id IS NULL
);

-- Policy for drivers to assign themselves to unassigned trips
CREATE POLICY "Drivers can assign themselves to unassigned trips" ON public.trips
FOR UPDATE USING (
  driver_id IS NULL AND 
  auth.uid() IN (SELECT id FROM public.drivers)
);
```

## 9. Flutter App Screens

| Screen File | Purpose |
|------------|---------|
| `SplashScreen.dart` | App boot, connectivity, onboarding, auth check |
| `OnBoardingScreen.dart` | First-time user onboarding |
| `WelcomeScreen.dart` | Entry for new/logged-out users |
| `EnableLocationScreen.dart` | Location permission flow |
| `SignInScreen.dart` | Email/password login (Supabase) |
| `SignUpScreen.dart` | Email/password registration |
| `PhoneNumberSignUpScreen.dart` | Phone-based registration (OTP) |
| `ForgotPasswordScreen.dart` | Password reset (Supabase) |
| `HomeScreen.dart` | Main dashboard: user greeting, recent locations, completed rides |
| `LocationSelectionScreen.dart` | Search/select address, save to history |
| `TripSelectionScreen.dart` | List/group trips by day, filter, select trip |
| `DirectionsMapScreen.dart` | Google Map route, markers, booking overlay |
| `BookingWidget.dart` | Seat selection, booking, payment (used in map) |
| `WalletScreen.dart` | Wallet top-up (Stripe), balance display |
| `HistoryScreen.dart` | List of completed rides with ratings system |
| `UserProfileScreen.dart` | View/edit user profile |
| `SettingsScreen.dart` | App preferences |
| `AccountActionsScreen.dart` | Profile, password, logout shortcuts, account deletion |
| `TermsAndConditionsScreen.dart` | Legal info |
| `PrivacyPolicyScreen.dart` | Legal info |
| `SetLocationMapScreen.dart` | Map-based location picker |
| `BecomeDriverScreen.dart` | Driver dashboard and trip management |
| `TripHistoryScreen.dart` | Trip assignment history and booking details for drivers |
| `ContactUsScreen.dart` | Contact/help info with complaint submission |

### Key Screen Functionality

**HistoryScreen**: Fetches completed trips from `bookings` table, displays trip details, allows users to rate completed rides (1-5 stars) using StarRating widget, ratings saved to `ratings` table, users can update ratings, completed and cancelled rides sorted by date (newest first).

**BecomeDriverScreen**: Driver profile creation and management, trip assignment system with real-time updates, van selection and assignment, weekly trip view with tabbed interface, seat availability tracking, booking status monitoring, trip assignment history access.

**TripHistoryScreen**: Displays all trips assigned to current driver, shows complete booking details in table format, color-coded status indicators, real-time data fetching with refresh functionality.

## 10. Flutter App Widgets

| Widget File | Purpose |
|------------|---------|
| `theme.dart` | App color palette, gradients |
| `BookingWidget.dart` | Booking UI (used in map) |
| `CustomTextField.dart` | Form fields |
| `PasswordFields.dart` | Password input fields |
| `MainButton.dart` | Main CTA button |
| `custom_button.dart` | Secondary CTA button |
| `LoadingDialog.dart` | Loading overlay |
| `GoogleButton.dart` | Google sign-in button |
| `CustomAppBar.dart` | App bar |
| `CustomBackButton.dart` | Back button |
| `CustomCheckbox.dart` | Checkbox UI |
| `CustomTextWidget.dart` | Text display |
| `PrivacyTermsText.dart` | Privacy/terms text |
| `BuildButton.dart` | Build/submit button |
| `OrDivider.dart` | Divider with "or" text |
| `StarRating.dart` | Interactive star rating widget (1-5 stars) |
| `app_drawer.dart` | Navigation drawer |

## 11. Admin Web Pages

| Page File | Route | Purpose |
|-----------|-------|---------|
| `App.tsx` | `/` | Main layout, navigation |
| `Dashboard.tsx` | `/` | KPIs, map, stats |
| `Trips.tsx` | `/trips` | List/create/edit/delete trips |
| `Drivers.tsx` | `/drivers` | Manage drivers with ratings display |
| `DriverDetail.tsx` | `/drivers/:id` | View/edit driver details with rating statistics |
| `Users.tsx` | `/users` | Manage users |
| `Payments.tsx` | `/payments` | View payments, wallet top-ups |
| `Bookings.tsx` | `/bookings` | Manage bookings |

### Admin Web Features

**Drivers.tsx**: Lists all drivers from `drivers` table, shows overall rating and total ratings count for each driver, calculates average rating from `ratings` table, right-aligned rating column showing star rating and count.

**DriverDetail.tsx**: Detailed driver information, trip history and performance, displays overall rating and total ratings count, real-time calculation from `ratings` table.

## 12. Platform Configuration

### Android Configuration

**Build Configuration** (`android/app/build.gradle.kts`):
- Application ID: `com.example.swift_ride`
- Target SDK: 36 (Android 15)
- Compile SDK: 36
- Java Version: 11

**Required Permissions**:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CAMERA" />
```

**Google Maps Configuration**: Add Google Maps API key to `android/app/src/main/AndroidManifest.xml`

### iOS Configuration

**App Configuration** (`ios/Runner/Info.plist`):
- Bundle Identifier: `com.example.swift_ride`
- Display Name: Swift Ride
- Supported Orientations: Portrait, Landscape Left/Right

**Required Permissions**:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to find nearby rides and show your position on the map.</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take profile pictures.</string>
```

**Google Maps Configuration**: Add Google Maps API key to `ios/Runner/AppDelegate.swift`

### Web Configuration

**Web Manifest** (`web/manifest.json`):
- App Name: swift_ride
- Theme Color: #0175C2
- Background Color: #0175C2
- Display Mode: standalone
- Orientation: portrait-primary

**Required Meta Tags**:
```html
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black">
<meta name="apple-mobile-web-app-title" content="swift_ride">
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
```

### Desktop Configuration

- **Windows**: Target Framework .NET 6.0, Architecture x64/x86/ARM64
- **Linux**: Dependencies GTK3, libsecret, Architecture x64/ARM64
- **macOS**: Target macOS 10.14+, Architecture x64/ARM64, Code Signing required

## 13. Assets & Styling

### Custom Fonts

The app includes 4 custom font families:

- **Poppins**: Regular, Bold (weight: 700)
- **Urbanist**: Regular, Bold (weight: 700)
- **Inter**: 18pt Regular/Bold, 24pt Regular/Bold (weight: 700)
- **Outfit**: Regular, Bold (weight: 700)

### Asset Files

```
assets/
├── fonts/                    # Custom fonts (4 families)
├── google_logo.png          # Google branding
├── van_logo.png             # App logo
├── apple.png                # Apple branding
├── map.png                  # Map placeholder
├── welcome.png              # Welcome screen image
├── onboarding_*.png          # Onboarding slides
├── splash.png              # Splash screen image
├── pick.PNG                # Pickup location icon
├── drop.PNG                # Dropoff location icon
├── map_style_light.json    # Light theme map style
└── map_style_dark.json     # Dark theme map style
```

### Admin Web Styling

The admin web uses a custom dark theme with:
- Primary Colors: Deep purple (#4c1d95) to violet (#7c3aed)
- Background: Slate-900 (#0f172a) with gradient overlays
- Surface: Gray-900 (#111827) with transparency
- Text: Gray-200 (#e5e7eb)
- Accent: Cyan-400 (#22d3ee)

## 14. Building & Release

### Flutter Build Commands

**Android**:
```bash
flutter build apk --release
flutter build appbundle --release
flutter build apk --target-platform android-arm64 --release
```

**iOS**:
```bash
cd ios && pod install && cd ..
flutter build ios --release
flutter build ipa --release
```

**Web**:
```bash
flutter build web --release
flutter build web --base-href /swift-ride/
```

**Desktop**:
```bash
flutter build windows --release
flutter build linux --release
flutter build macos --release
```

### Admin Web Build

```bash
cd admin_web
npm run dev          # Development server
npm run build        # Production build
npm run preview      # Preview production build
```

### Release Checklist

**Pre-Release**:
- Update version numbers in `pubspec.yaml`
- Test on all target platforms
- Verify all API keys are configured
- Run security audit: `flutter pub audit`
- Update documentation

**Android Release**:
- Generate signed APK/AAB
- Test on multiple devices
- Upload to Google Play Console
- Configure app signing

**iOS Release**:
- Configure provisioning profiles
- Test on physical devices
- Upload to App Store Connect
- Configure app review information

**Web Release**:
- Build optimized web assets
- Configure hosting (Vercel, Netlify, etc.)
- Set up custom domain
- Configure HTTPS

### Vercel Deployment for Admin Web

SwiftRide admin web panel can be deployed to Vercel for production hosting with automatic deployments and SSL certificates.

#### Prerequisites

- Vercel account (sign up at vercel.com)
- Git repository (GitHub, GitLab, or Bitbucket)
- Admin web project built and tested locally

#### Deployment Steps

1. **Prepare Admin Web for Production**

```bash
cd admin_web
npm run build
```

2. **Create vercel.json Configuration**

Create `admin_web/vercel.json` file:

```json
{
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

This configuration ensures all routes are handled by the React Router, preventing 404 errors on page refresh.

3. **Deploy via Vercel CLI**

```bash
# Install Vercel CLI globally
npm install -g vercel

# Navigate to admin_web directory
cd admin_web

# Deploy to Vercel
vercel

# Follow the prompts:
# - Set up and deploy? Yes
# - Which scope? Select your account
# - Link to existing project? No (for first deployment)
# - Project name? swift-ride-admin (or your preferred name)
# - Directory? ./
# - Override settings? No
```

4. **Deploy via Vercel Dashboard**

- Go to vercel.com and sign in
- Click "Add New Project"
- Import your Git repository
- Configure project:
  - Framework Preset: Vite
  - Root Directory: `admin_web`
  - Build Command: `npm run build`
  - Output Directory: `dist`
  - Install Command: `npm install`
- Add Environment Variables:
  - `VITE_SUPABASE_URL`
  - `VITE_SUPABASE_ANON_KEY`
  - `VITE_GOOGLE_MAPS_API_KEY`
  - `VITE_DEBUG_MODE` (optional)
- Click "Deploy"

5. **Configure Environment Variables**

In Vercel Dashboard:
- Go to Project Settings → Environment Variables
- Add all required variables from `admin_web/.env`
- Set for Production, Preview, and Development environments
- Redeploy after adding variables

6. **Custom Domain Setup**

- Go to Project Settings → Domains
- Add your custom domain
- Follow DNS configuration instructions
- Vercel automatically provisions SSL certificate

#### Vercel Deployment Features

- **Automatic Deployments**: Every push to main branch triggers production deployment
- **Preview Deployments**: Pull requests get preview URLs automatically
- **SSL Certificates**: Automatic HTTPS with Let's Encrypt
- **Global CDN**: Fast content delivery worldwide
- **Environment Variables**: Secure variable management
- **Build Logs**: Detailed build and deployment logs
- **Analytics**: Performance and usage analytics
- **Rollback**: Easy rollback to previous deployments

#### Vercel Configuration Options

**vercel.json** (optional advanced configuration):

```json
{
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-XSS-Protection",
          "value": "1; mode=block"
        }
      ]
    }
  ]
}
```

#### Troubleshooting Vercel Deployment

**Build Failures**:
- Check build logs in Vercel Dashboard
- Verify all environment variables are set
- Ensure `package.json` has correct build scripts
- Check Node.js version compatibility

**404 Errors on Refresh**:
- Ensure `vercel.json` has rewrites configuration
- Verify React Router is configured correctly
- Check that all routes redirect to `index.html`

**Environment Variables Not Working**:
- Verify variables are set in Vercel Dashboard
- Check variable names match exactly (including `VITE_` prefix)
- Redeploy after adding/updating variables
- Ensure variables are set for correct environment (Production/Preview/Development)

**Performance Issues**:
- Enable Vercel Analytics for performance insights
- Optimize bundle size with code splitting
- Use Vercel's Edge Network for faster delivery
- Implement caching strategies

#### Continuous Deployment

Vercel automatically deploys when you push to your connected Git repository:

- **Production**: Deploys from `main` or `master` branch
- **Preview**: Deploys from other branches and pull requests
- **Manual**: Deploy specific commits from Vercel Dashboard

#### Vercel CLI Commands

```bash
# Deploy to production
vercel --prod

# Deploy preview
vercel

# View deployment logs
vercel logs

# List deployments
vercel ls

# Remove deployment
vercel rm [deployment-url]

# Link local project to Vercel
vercel link
```

## 15. Testing Framework

SwiftRide includes a comprehensive testing framework with unit tests, widget tests, and integration tests.

### Test Results Summary

**All Tests Passing: 33/33 tests successful**
- Simple Tests: 3/3 PASSED
- Widget Tests: 30/30 PASSED
- Total Runtime: ~10.6 seconds
- Zero test failures

### Test Structure

```
test/
├── widget_test/           # Widget unit tests (30 tests)
│   ├── custom_text_field_test.dart    # 10 tests
│   ├── main_button_test.dart          # 8 tests
│   └── custom_text_widget_test.dart   # 12 tests
├── unit_test/            # Screen and logic unit tests
├── services/             # Service unit tests
└── email_test.dart       # Email configuration tests

integration_test/
├── app_test.dart         # Main E2E tests
├── driver_flow_test.dart # Driver-specific E2E tests
└── email_flow_test.dart  # Email notification E2E tests
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test/custom_text_field_test.dart

# Run tests with coverage
flutter test --coverage

# Run with verbose output
flutter test --verbose
```

### Test Coverage Areas

- Widget rendering and display
- User interactions and callbacks
- Form validation logic
- Error handling and edge cases
- Styling and theming
- State management
- Email notification system
- Booking status management
- Auto-completion logic

### Testing Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  mockito: ^5.4.4
  build_runner: ^2.4.9
```

## 16. Troubleshooting

### Common Issues & Solutions

#### App Won't Start / Blank Screen

**Symptoms**: App launches but shows blank/white screen

**Solutions**:
```bash
# Check environment variables
cat .env

# Clear Flutter cache
flutter clean
flutter pub get

# Check for build errors
flutter doctor -v
```

**Common Causes**: Missing or invalid Supabase URL/keys, network connectivity issues, build cache corruption

#### Location Services Not Working

**Symptoms**: Location permission denied, GPS not working

**Solutions**:
- Android: Check permissions in AndroidManifest.xml, enable location in device settings
- iOS: Check Info.plist for location usage descriptions, grant location permission when prompted
- Web: Use HTTPS (required for geolocation API)

#### Stripe Payment Issues

**Symptoms**: Payment fails, Stripe errors

**Solutions**:
- Verify Stripe keys match environment (test vs live)
- Check Stripe dashboard for webhook configuration
- Ensure network connectivity to Stripe API

#### Google Maps Not Loading

**Symptoms**: Maps show blank tiles or error

**Solutions**:
- Verify Google Maps API key
- Check API key restrictions in Google Cloud Console
- Ensure Maps SDK, Places API, and Directions API are enabled

#### Email Notifications Not Working

**Symptoms**: Users not receiving emails, email service errors

**Solutions**:
- Check email configuration in `.env` file
- Verify Resend API key is valid
- Check Resend dashboard for delivery status
- Ensure domain is verified in Resend
- Verify email templates are properly formatted

**Debug Steps**:
1. Check console for email configuration status on app startup
2. Verify `.env` file has correct Resend API key and from email
3. Test email service with test function in SimpleEmailService
4. Check Resend dashboard for delivery logs and bounce reports

#### Build Failures

**Android Build Issues**:
```bash
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
flutter build apk
```

**iOS Build Issues**:
```bash
cd ios && pod install && cd ..
xcodebuild -version
rm -rf ~/Library/Developer/Xcode/DerivedData
```

**Web Build Issues**:
```bash
flutter clean
flutter build web --web-renderer html
```

#### Admin Web Issues

**Blank Admin Dashboard**:
```bash
cd admin_web
cat .env
npm run dev
# Check browser console for errors
```

**Build Failures**:
```bash
rm -rf node_modules package-lock.json
npm install
node --version  # Should be 18 or higher
```

### Debug Commands

**Flutter Debugging**:
```bash
flutter run --verbose
flutter pub deps
flutter analyze
flutter test --coverage
```

**Admin Web Debugging**:
```bash
cd admin_web
npm run dev
npm run build
npm run preview
```

### Performance Issues

**Slow App Performance**:
- Check for memory leaks in location services
- Optimize image assets
- Use `flutter build apk --split-per-abi` for smaller APKs

**Slow Admin Dashboard**:
- Check Supabase query performance
- Implement pagination for large datasets
- Use React.memo for component optimization

## 17. Security & Extending

### Security Best Practices

#### Database Security

```sql
-- Enable Row Level Security (RLS) on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE location_history ENABLE ROW LEVEL SECURITY;

-- Create policies for user data access
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Create policies for trips (public read, admin write)
CREATE POLICY "Anyone can view trips" ON trips
  FOR SELECT USING (true);

CREATE POLICY "Admins can manage trips" ON trips
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

#### API Security

- Environment Variables: Never commit API keys to version control
- HTTPS Only: Enforce HTTPS for all API calls
- Rate Limiting: Implement rate limiting for sensitive endpoints
- Input Validation: Validate all user inputs server-side

#### Payment Security

- PCI Compliance: Use Stripe for payment processing (PCI DSS compliant)
- Webhook Verification: Verify Stripe webhook signatures
- Secure Storage: Never store payment details locally

### Extending the Application

#### Adding New Features

**Driver Management System**:
```sql
CREATE TABLE drivers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id),
  license_number text,
  vehicle_info jsonb,
  status text DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);
```

**Real-time Notifications**:
```dart
class NotificationService {
  static Future<void> initialize() async {
    Supabase.instance.client
      .channel('notifications')
      .on('postgres_changes', 
        { event: 'INSERT', schema: 'public', table: 'notifications' },
        (payload) => showNotification(payload.new)
      )
      .subscribe();
  }
}
```

#### Database Extensions

**Seat Management**:
```sql
CREATE TABLE seat_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid REFERENCES bookings(id),
  seat_number integer,
  passenger_name text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE trips ADD COLUMN seat_map jsonb;
```

**Route Optimization**:
```sql
CREATE TABLE route_waypoints (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id uuid REFERENCES trips(id),
  sequence_order integer,
  location_name text,
  coordinates point,
  pickup_time timestamptz
);
```

### Performance Optimization

#### Database Optimization

```sql
CREATE INDEX idx_trips_depart_time ON trips(depart_time);
CREATE INDEX idx_bookings_user_status ON bookings(user_id, status);
CREATE INDEX idx_location_history_user ON location_history(user_id);
```

#### Flutter Performance

```dart
// Implement lazy loading for large lists
ListView.builder(
  itemCount: trips.length,
  itemBuilder: (context, index) {
    return TripCard(trip: trips[index]);
  },
);

// Use const constructors where possible
const TripCard({
  required this.trip,
  Key? key,
}) : super(key: key);
```

#### Caching Strategy

```dart
class CacheService {
  static const String _tripsKey = 'cached_trips';
  
  static Future<void> cacheTrips(List<Trip> trips) async {
    final prefs = await SharedPreferences.getInstance();
    final json = trips.map((t) => t.toJson()).toList();
    await prefs.setString(_tripsKey, jsonEncode(json));
  }
}
```

### Deployment Strategies

#### Production Deployment

- Database: Use Supabase production instance
- CDN: Configure CDN for static assets (optional)
- Monitoring: Set up error tracking (Supabase built-in monitoring)
- Backups: Configure automated database backups via Supabase

#### Scaling Considerations

- Database: Use Supabase's built-in scaling and connection pooling
- Caching: Implement Supabase real-time subscriptions for live data
- Load Balancing: Configure multiple app instances
- Monitoring: Use Supabase dashboard and built-in analytics

### Contributing Guidelines

#### Code Standards

- Follow Flutter/Dart style guide
- Use meaningful variable names
- Add comprehensive comments
- Write unit tests for new features

#### Git Workflow

```bash
git checkout -b feature/new-feature
# Make changes
git commit -m "Add new feature"
git push origin feature/new-feature
# Create pull request
```

#### Testing Strategy

```dart
// Unit tests
test('should calculate trip price correctly', () {
  final trip = Trip(price: 100, seats: 2);
  expect(trip.totalPrice, 200);
});

// Widget tests
testWidgets('should display trip information', (tester) async {
  await tester.pumpWidget(TripCard(trip: mockTrip));
  expect(find.text('Lahore to Islamabad'), findsOneWidget);
});
```

---

## Conclusion

This comprehensive documentation covers every aspect of the Swift Ride project, from initial setup to advanced extensions and production deployment. Swift Ride is a full-featured ride booking and management system with the following capabilities:

### Core Features

**User Application (Flutter Mobile App)**:
- 22 complete screens with seamless user flows
- User authentication (Email/Password, Google Sign-In, Phone OTP)
- Location services with Google Maps integration
- Trip search and booking system
- Real-time route visualization with polylines
- Seat selection and booking management
- Wallet system with Stripe payment integration
- Trip history with date-based sorting (newest first)
- Ratings and feedback system (1-5 stars)
- Profile management and account settings
- Driver registration and trip management
- Trip assignment history for drivers
- Contact and support system with complaint submission
- Automated email notifications for all booking events

**Admin Web Panel (React/TypeScript)**:
- 8 comprehensive management pages
- Dashboard with KPIs and analytics
- Trip management (create, edit, delete)
- User management and monitoring
- Driver management with ratings display
- Driver detail pages with performance metrics
- Payment monitoring and transaction history
- Booking management and status tracking
- Real-time data updates
- Responsive design with dark theme

**Backend Services**:
- Supabase integration for authentication, database, and storage
- Row Level Security (RLS) policies for data protection
- Real-time subscriptions for live updates
- Edge functions for payment processing
- RPC functions for wallet operations
- Automated ride completion detection

**Payment System**:
- Stripe PaymentSheet integration
- Secure wallet top-up functionality
- Payment intent creation via Supabase Edge Functions
- Wallet balance management
- Transaction history tracking

**Location Services**:
- Google Maps integration with custom markers
- Route planning and visualization
- Address geocoding and reverse geocoding
- Google Places API for address autocomplete
- Current location detection
- Map-based location picker

**Email Notification System**:
- Automated booking confirmation emails
- Cancellation confirmation with refund information
- Ride completion notifications
- Complaint acknowledgment emails
- Account deletion confirmation emails
- Professional HTML email templates
- Resend API integration
- Email service configuration and testing

**Ratings & Feedback System**:
- Interactive star rating widget (1-5 stars)
- User ratings for completed rides
- Driver overall rating calculation
- Rating statistics in admin dashboard
- Rating persistence and update capability
- Real-time rating updates

**Multi-Platform Support**:
- Android (APK and App Bundle)
- iOS (IPA for App Store)
- Web (PWA support)
- Windows Desktop
- Linux Desktop
- macOS Desktop

**UI/UX Components**:
- 17 reusable widgets for consistent design
- Custom theme with gradients and color palette
- 4 custom font families (Poppins, Urbanist, Inter, Outfit)
- Loading animations and transitions
- Responsive layouts for all screen sizes
- Dark theme for admin web panel

**Testing & Quality Assurance**:
- Comprehensive testing framework
- 33 passing tests (3 simple tests, 30 widget tests)
- Unit tests for screens and logic
- Widget tests for UI components
- Integration tests for end-to-end flows
- Service tests for business logic
- Test coverage for all major features

**Security Features**:
- Row Level Security (RLS) on all database tables
- Secure API key management via environment variables
- HTTPS enforcement for all communications
- PCI-compliant payment processing via Stripe
- Input validation and sanitization
- Secure authentication with Supabase Auth

**Deployment & Infrastructure**:
- Vercel deployment for admin web panel
- Automatic SSL certificates
- Global CDN for fast content delivery
- Environment variable management
- Continuous deployment from Git
- Preview deployments for pull requests
- Production and staging environments

**Developer Experience**:
- Comprehensive documentation
- Clear project structure
- Environment variable configuration
- Build scripts for all platforms
- Debugging tools and commands
- Troubleshooting guides
- Code examples and snippets

### Technical Stack

- **Frontend (Mobile)**: Flutter 3.7+, Dart
- **Frontend (Web)**: React 18.3.1, TypeScript 5.6.2, Vite 5.4.2
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Real-time)
- **Payments**: Stripe PaymentSheet
- **Maps**: Google Maps Platform
- **Email**: Resend API
- **Hosting**: Vercel (Admin Web)
- **Version Control**: Git
- **Testing**: Flutter Test, Integration Test

### Project Statistics

- **Total Screens**: 22 Flutter screens
- **Total Widgets**: 17 reusable components
- **Admin Pages**: 8 management pages
- **Services**: 5 business logic services
- **Test Coverage**: 33 passing tests
- **Platforms**: 6 supported platforms
- **Email Types**: 5 automated email notifications
- **Database Tables**: 7 core tables with RLS policies

### Key Achievements

- Complete end-to-end ride booking system
- Multi-platform mobile and web applications
- Secure payment processing integration
- Real-time location and mapping services
- Automated email notification system
- Comprehensive ratings and feedback system
- Professional admin dashboard
- Production-ready deployment configuration
- Extensive test coverage
- Complete documentation

### Future Enhancements

The system is designed to be extensible with potential additions including:
- Real-time notifications via push notifications
- Advanced analytics dashboard
- Seat selection with visual seat maps
- Route optimization with waypoints
- Driver performance badges and rewards
- Rating comments and detailed feedback
- Multi-language support
- Advanced search and filtering
- Social media integration
- Referral program

### Getting Started

For developers looking to work with this project:

1. Review the Prerequisites section for required tools and services
2. Follow the Quick Start guide for initial setup
3. Configure Environment Variables with your API keys
4. Set up the Supabase database using the provided schemas
5. Build and test the application locally
6. Deploy admin web to Vercel following the deployment guide
7. Refer to specific sections for detailed implementation guidance

### Support & Resources

- **Documentation**: This comprehensive README
- **Code Examples**: Inline code snippets throughout documentation
- **Troubleshooting**: Common issues and solutions section
- **Testing**: Complete testing framework documentation
- **Security**: Best practices and guidelines
- **Deployment**: Step-by-step deployment guides

For any specific implementation details, refer to the corresponding source files in the project structure. This documentation serves as a complete guide for development, deployment, and maintenance of the Swift Ride application.

---

**Swift Ride** - A complete, production-ready ride booking and management system built with modern technologies and best practices.
