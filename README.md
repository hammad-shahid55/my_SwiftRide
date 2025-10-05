# Swift Ride — Complete Project Guide

Swift Ride is a comprehensive cross-platform ride booking and management system, featuring:

- **Flutter Mobile App** (for users and drivers) - Cross-platform mobile application
- **React/TypeScript Admin Web Panel** - Complete admin dashboard for management
- **Supabase Backend** - Authentication, database, storage, and real-time features
- **Stripe Integration** - Secure payment processing and wallet management
- **Google Maps Integration** - Route planning, location services, and navigation
- **Multi-platform Support** - Android, iOS, Web, and Desktop builds

This guide covers setup, configuration, architecture, and every screen/page in sequence with complete documentation.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Quick Start (Flutter & Admin Web)](#2-quick-start)
3. [Environment Variables](#3-environment-variables)
4. [Project Structure](#4-project-structure)
5. [Core Dependencies](#5-core-dependencies)
6. [App Initialization Flow](#6-app-initialization-flow)
7. [Supabase & Stripe Integration](#7-supabase--stripe-integration)
8. [Data Model & Database Logic](#8-data-model--database-logic)
9. [Flutter App: All Screens (in order)](#9-flutter-app-all-screens-in-order)
10. [Flutter App: All Widgets](#10-flutter-app-all-widgets)
11. [Admin Web: All Pages (in order)](#11-admin-web-all-pages-in-order)
12. [Platform-Specific Configuration](#12-platform-specific-configuration)
13. [Assets & Styling](#13-assets--styling)
14. [Building & Release](#14-building--release)
15. [Troubleshooting](#15-troubleshooting)
16. [Security & Extending](#16-security--extending)

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

## 2. Quick Start

### Flutter App

```bash
# Clone the repository
git clone <repository-url>
cd my_SwiftRide

# Install dependencies
flutter pub get

# Create environment file
cp .env.example .env
# Edit .env with your API keys (see Environment Variables section)

# Run the app
flutter run
```

### Admin Web

```bash
# Navigate to admin web directory
cd admin_web

# Install dependencies
npm install

# Create environment file
cp .env.example .env
# Edit .env with your Supabase credentials

# Start development server
npm run dev

# Build for production
npm run build
```

### First-Time Setup Checklist

1. **Environment Setup**
   - Create `.env` file in project root
   - Create `admin_web/.env` file
   - Add all required API keys (see Environment Variables section)

2. **Database Setup**
   - Set up Supabase project
   - Create required tables (see Data Model section)
   - Configure Row Level Security (RLS)

3. **External Services**
   - Configure Stripe webhook endpoints
   - Set up Google Maps API
   - Configure Google Sign-In OAuth

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
| `SUPABASE_URL` | Supabase project URL | ✅ | Flutter |
| `SUPABASE_ANON_KEY` | Supabase anonymous key | ✅ | Flutter |
| `STRIPE_PUBLISHABLE_KEY` | Stripe publishable key | ✅ | Flutter |
| `GOOGLE_MAPS_API_KEY` | Google Maps API key | ✅ | Flutter |
| `GOOGLE_SIGN_IN_CLIENT_ID` | Google OAuth client ID | ✅ | Flutter |
| `VITE_SUPABASE_URL` | Supabase project URL | ✅ | Admin Web |
| `VITE_SUPABASE_ANON_KEY` | Supabase anonymous key | ✅ | Admin Web |
| `VITE_GOOGLE_MAPS_API_KEY` | Google Maps API key | ✅ | Admin Web |

---

## 4. Project Structure

```
my_SwiftRide/
├── lib/                          # Flutter app source code
│   ├── main.dart                 # App entry point
│   ├── Screens/                  # All app screens (22 files)
│   │   ├── SplashScreen.dart
│   │   ├── OnBoardingScreen.dart
│   │   ├── WelcomeScreen.dart
│   │   ├── SignInScreen.dart
│   │   ├── SignUpScreen.dart
│   │   ├── HomeScreen.dart
│   │   ├── LocationSelectionScreen.dart
│   │   ├── TripSelectionScreen.dart
│   │   ├── DirectionsMapScreen.dart
│   │   ├── WalletScreen.dart
│   │   ├── HistoryScreen.dart
│   │   ├── UserProfileScreen.dart
│   │   ├── SettingsScreen.dart
│   │   ├── BecomeDriverScreen.dart
│   │   └── ... (8 more screens)
│   └── Widgets/                  # Reusable UI components (16 files)
│       ├── theme.dart
│       ├── BookingWidget.dart
│       ├── CustomTextField.dart
│       ├── MainButton.dart
│       ├── LoadingDialog.dart
│       └── ... (11 more widgets)
├── assets/                       # Static assets
│   ├── fonts/                   # Custom fonts (4 families)
│   │   ├── Poppins/
│   │   ├── Urbanist/
│   │   ├── Inter/
│   │   └── Outfit/
│   ├── google_logo.png
│   ├── van_logo.png
│   ├── map_style_light.json
│   ├── map_style_dark.json
│   └── ... (onboarding images, icons)
├── admin_web/                   # React admin dashboard
│   ├── src/
│   │   ├── main.tsx            # Admin app entry point
│   │   ├── pages/              # Admin pages (8 files)
│   │   │   ├── App.tsx
│   │   │   ├── Dashboard.tsx
│   │   │   ├── Trips.tsx
│   │   │   ├── Users.tsx
│   │   │   ├── Drivers.tsx
│   │   │   ├── Payments.tsx
│   │   │   ├── Bookings.tsx
│   │   │   └── DriverDetail.tsx
│   │   ├── lib/
│   │   │   └── supabaseClient.ts
│   │   └── styles.css
│   ├── package.json
│   ├── vite.config.ts
│   ├── tsconfig.json
│   └── index.html
├── android/                     # Android platform files
│   ├── app/
│   │   ├── build.gradle.kts
│   │   └── src/main/
│   ├── build.gradle.kts
│   └── gradle.properties
├── ios/                         # iOS platform files
│   ├── Runner/
│   │   ├── Info.plist
│   │   ├── AppDelegate.swift
│   │   └── Assets.xcassets/
│   └── Runner.xcodeproj/
├── web/                         # Web platform files
│   ├── index.html
│   ├── manifest.json
│   └── icons/
├── windows/                     # Windows platform files
├── linux/                       # Linux platform files
├── macos/                       # macOS platform files
├── pubspec.yaml                 # Flutter dependencies
├── .env                         # Environment variables
└── README.md                    # This documentation
```

### Key Directories Explained

- **`lib/Screens/`**: Contains all 22 app screens with complete user flows
- **`lib/Widgets/`**: Contains 16 reusable UI components and widgets
- **`assets/`**: Static resources including fonts, images, and map styles
- **`admin_web/`**: Complete React/TypeScript admin dashboard
- **Platform folders**: Platform-specific configurations for Android, iOS, Web, Windows, Linux, macOS

---

## 5. Core Dependencies

### Flutter Dependencies

#### Backend & Authentication
- **`supabase_flutter: ^2.9.1`** - Supabase client for auth, database, storage
- **`google_sign_in: ^7.1.0`** - Google OAuth authentication
- **`flutter_dotenv: ^6.0.0`** - Environment variables management

#### Payment Processing
- **`flutter_stripe: ^11.5.0`** - Stripe payment integration
- **`http: ^0.13.6`** - HTTP requests for payment processing

#### Maps & Location Services
- **`google_maps_flutter: ^2.12.3`** - Google Maps integration
- **`geolocator: ^14.0.2`** - Location services and permissions
- **`geocoding: ^4.0.0`** - Address geocoding
- **`google_place: ^0.4.7`** - Google Places API
- **`google_maps_webservice: ^0.0.20-nullsafety.5`** - Google Maps web services
- **`flutter_polyline_points: ^1.0.0`** - Route polyline rendering

#### UI & Animations
- **`animated_text_kit: ^4.2.3`** - Text animations
- **`loading_animation_widget: ^1.3.0`** - Loading animations
- **`flutter_native_splash: ^2.4.6`** - Native splash screen

#### Utilities
- **`connectivity_plus: ^6.1.4`** - Network connectivity
- **`shared_preferences: ^2.5.3`** - Local storage
- **`intl: ^0.20.2`** - Internationalization
- **`timezone: ^0.9.4`** - Timezone handling
- **`image_picker: ^1.1.2`** - Image selection
- **`otp_text_field: ^1.1.3`** - OTP input fields

### Admin Web Dependencies

#### Core Framework
- **`react: ^18.3.1`** - React framework
- **`react-dom: ^18.3.1`** - React DOM rendering
- **`react-router-dom: ^6.26.2`** - Client-side routing

#### Backend Integration
- **`@supabase/supabase-js: ^2.45.4`** - Supabase JavaScript client

#### Development Tools
- **`vite: ^5.4.2`** - Build tool and dev server
- **`typescript: ^5.6.2`** - TypeScript support
- **`@vitejs/plugin-react: ^4.3.2`** - Vite React plugin
- **`@types/react: ^18.3.5`** - React TypeScript types
- **`@types/react-dom: ^18.3.0`** - React DOM TypeScript types

### Dependency Categories

| Category | Flutter Packages | Purpose |
|----------|------------------|---------|
| **Backend** | supabase_flutter, google_sign_in | Authentication & data |
| **Payments** | flutter_stripe, http | Payment processing |
| **Maps** | google_maps_flutter, geolocator, geocoding | Location services |
| **UI** | animated_text_kit, loading_animation_widget | User interface |
| **Storage** | shared_preferences, connectivity_plus | Local data & network |
| **Utils** | intl, timezone, image_picker | Utilities |

---

## 6. App Initialization Flow (Flutter)

`main.dart` loads `.env`, initializes Supabase and Stripe, then launches the app:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(url: ..., anonKey: ...);
  Stripe.publishableKey = ...;
  runApp(MainApp());
}
```

---

## 7. Supabase & Stripe Integration

- Supabase: Auth, database, storage, edge functions (for payments)
- Stripe: PaymentSheet for wallet top-up
- Google Maps: Route, distance, and location features

---

## 8. Data Model & Database Logic

- `profiles`: user info, wallet balance
- `location_history`: recent locations
- `trips`: all available trips
- `bookings`: user bookings
- Edge function: `create-payment-intent` (Stripe)
- RPC: `increment_wallet` (wallet top-up)

---

## 9. Flutter App: All Screens (in sequence)

| Screen File                     | Purpose                                                          |
| ------------------------------- | ---------------------------------------------------------------- |
| `SplashScreen.dart`             | App boot, connectivity, onboarding, auth check                   |
| `OnBoardingScreen.dart`         | First-time user onboarding                                       |
| `WelcomeScreen.dart`            | Entry for new/logged-out users                                   |
| `EnableLocationScreen.dart`     | Location permission flow                                         |
| `SignInScreen.dart`             | Email/password login (Supabase)                                  |
| `SignUpScreen.dart`             | Email/password registration                                      |
| `PhoneNumberSignUpScreen.dart`  | Phone-based registration (OTP)                                   |
| `ForgotPasswordScreen.dart`     | Password reset (Supabase)                                        |
| `HomeScreen.dart`               | Main dashboard: user greeting, recent locations, completed rides |
| `LocationSelectionScreen.dart`  | Search/select address, save to history                           |
| `TripSelectionScreen.dart`      | List/group trips by day, filter, select trip                     |
| `DirectionsMapScreen.dart`      | Google Map route, markers, booking overlay                       |
| `BookingWidget.dart`            | Seat selection, booking, payment (used in map)                   |
| `WalletScreen.dart`             | Wallet top-up (Stripe), balance display                          |
| `HistoryScreen.dart`            | List of completed rides                                          |
| `UserProfileScreen.dart`        | View/edit user profile                                           |
| `SettingsScreen.dart`           | App preferences                                                  |
| `AccountActionsScreen.dart`     | Profile, password, logout shortcuts                              |
| `TermsAndConditionsScreen.dart` | Legal info                                                       |
| `PrivacyPolicyScreen.dart`      | Legal info                                                       |
| `SetLocationMapScreen.dart`     | Map-based location picker                                        |
| `BecomeDriverScreen.dart`       | Driver onboarding                                                |
| `ContactUsScreen.dart`          | Contact/help info                                                |

---

## 10. Flutter App: All Widgets (reusable)

| Widget File             | Purpose                      |
| ----------------------- | ---------------------------- |
| `theme.dart`            | App color palette, gradients |
| `BookingWidget.dart`    | Booking UI (used in map)     |
| `CustomTextField.dart`  | Form fields                  |
| `PasswordFields.dart`   | Password input fields        |
| `MainButton.dart`       | Main CTA button              |
| `custom_button.dart`    | Secondary CTA button         |
| `LoadingDialog.dart`    | Loading overlay              |
| `GoogleButton.dart`     | Google sign-in button        |
| `CustomAppBar.dart`     | App bar                      |
| `CustomBackButton.dart` | Back button                  |
| `CustomCheckbox.dart`   | Checkbox UI                  |
| `CustomTextWidget.dart` | Text display                 |
| `PrivacyTermsText.dart` | Privacy/terms text           |
| `BuildButton.dart`      | Build/submit button          |
| `OrDivider.dart`        | Divider with "or" text       |
| `app_drawer.dart`       | Navigation drawer            |

---

## 11. Admin Web: All Pages (in sequence)

| Page File          | Route          | Purpose                       |
| ------------------ | -------------- | ----------------------------- |
| `App.tsx`          | `/`            | Main layout, navigation       |
| `Dashboard.tsx`    | `/`            | KPIs, map, stats              |
| `Trips.tsx`        | `/trips`       | List/create/edit/delete trips |
| `Drivers.tsx`      | `/drivers`     | Manage drivers                |
| `DriverDetail.tsx` | `/drivers/:id` | View/edit driver details      |
| `Users.tsx`        | `/users`       | Manage users                  |
| `Payments.tsx`     | `/payments`    | View payments, wallet top-ups |
| `Bookings.tsx`     | `/bookings`    | Manage bookings               |

---

## 12. Platform-Specific Configuration

### Android Configuration

#### Build Configuration (`android/app/build.gradle.kts`)
- **Application ID**: `com.example.swift_ride`
- **Target SDK**: 35 (Android 15)
- **Min SDK**: Flutter default
- **Compile SDK**: 35
- **Java Version**: 11

#### Required Permissions
```xml
<!-- Location permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Network permissions -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Camera permissions (for image picker) -->
<uses-permission android:name="android.permission.CAMERA" />
```

#### Google Maps Configuration
- Add Google Maps API key to `android/app/src/main/AndroidManifest.xml`
- Configure Google Sign-In in `google-services.json`

### iOS Configuration

#### App Configuration (`ios/Runner/Info.plist`)
- **Bundle Identifier**: `com.example.swift_ride`
- **Display Name**: Swift Ride
- **Supported Orientations**: Portrait, Landscape Left/Right

#### Required Permissions
```xml
<!-- Location permissions -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to find nearby rides and show your position on the map.</string>

<!-- Camera permissions -->
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take profile pictures.</string>
```

#### Google Maps Configuration
- Add Google Maps API key to `ios/Runner/AppDelegate.swift`
- Configure URL schemes for Google Sign-In

### Web Configuration

#### Web Manifest (`web/manifest.json`)
- **App Name**: swift_ride
- **Theme Color**: #0175C2
- **Background Color**: #0175C2
- **Display Mode**: standalone
- **Orientation**: portrait-primary

#### Required Meta Tags
```html
<!-- PWA support -->
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black">
<meta name="apple-mobile-web-app-title" content="swift_ride">

<!-- Google Maps -->
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
```

### Desktop Configuration (Windows/Linux/macOS)

#### Windows
- **Target Framework**: .NET 6.0
- **Architecture**: x64, x86, ARM64
- **Dependencies**: Visual C++ Redistributable

#### Linux
- **Dependencies**: GTK3, libsecret
- **Architecture**: x64, ARM64
- **Package Format**: AppImage, Snap, Flatpak

#### macOS
- **Target**: macOS 10.14+
- **Architecture**: x64, ARM64 (Apple Silicon)
- **Code Signing**: Required for distribution

## 13. Assets & Styling

### Custom Fonts
The app includes 4 custom font families:

#### Poppins Font Family
- **Regular**: `assets/fonts/Poppins-Regular.ttf`
- **Bold**: `assets/fonts/Poppins-Bold.ttf` (weight: 700)

#### Urbanist Font Family
- **Regular**: `assets/fonts/Urbanist-Regular.ttf`
- **Bold**: `assets/fonts/Urbanist-Bold.ttf` (weight: 700)

#### Inter Font Family
- **18pt Regular**: `assets/fonts/Inter_18pt-Regular.ttf`
- **18pt Bold**: `assets/fonts/Inter_18pt-Bold.ttf`
- **24pt Regular**: `assets/fonts/Inter_24pt-Regular.ttf`
- **24pt Bold**: `assets/fonts/Inter_24pt-Bold.ttf` (weight: 700)

#### Outfit Font Family
- **Regular**: `assets/fonts/Outfit-Regular.ttf`
- **Bold**: `assets/fonts/Outfit-Bold.ttf` (weight: 700)

### Asset Files
```
assets/
├── fonts/                    # Custom fonts (4 families)
├── google_logo.png          # Google branding
├── van_logo.png             # App logo
├── apple.png                # Apple branding
├── map.png                  # Map placeholder
├── welcome.png              # Welcome screen image
├── onboarding_1.png         # Onboarding slide 1
├── onboarding_3.png         # Onboarding slide 3
├── onboarding_4.png        # Onboarding slide 4
├── splash.png              # Splash screen image
├── pick.PNG                # Pickup location icon
├── drop.PNG                # Dropoff location icon
├── map_style_light.json    # Light theme map style
└── map_style_dark.json     # Dark theme map style
```

### Admin Web Styling
The admin web uses a custom dark theme with:
- **Primary Colors**: Deep purple (#4c1d95) to violet (#7c3aed)
- **Background**: Slate-900 (#0f172a) with gradient overlays
- **Surface**: Gray-900 (#111827) with transparency
- **Text**: Gray-200 (#e5e7eb)
- **Accent**: Cyan-400 (#22d3ee)

## 14. Building & Release

### Flutter Build Commands

#### Android
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App bundle (recommended for Play Store)
flutter build appbundle --release

# Specific architecture
flutter build apk --target-platform android-arm64 --release
```

#### iOS
```bash
# Install pods first
cd ios && pod install && cd ..

# Debug build
flutter build ios --debug

# Release build
flutter build ios --release

# Archive for App Store
flutter build ipa --release
```

#### Web
```bash
# Debug build
flutter build web --debug

# Release build
flutter build web --release

# With specific base href
flutter build web --base-href /swift-ride/
```

#### Desktop
```bash
# Windows
flutter build windows --release

# Linux
flutter build linux --release

# macOS
flutter build macos --release
```

### Admin Web Build

```bash
# Development server
cd admin_web
npm run dev

# Production build
npm run build

# Preview production build
npm run preview
```

### Release Checklist

#### Pre-Release
- [ ] Update version numbers in `pubspec.yaml`
- [ ] Test on all target platforms
- [ ] Verify all API keys are configured
- [ ] Run security audit: `flutter pub audit`
- [ ] Update documentation

#### Android Release
- [ ] Generate signed APK/AAB
- [ ] Test on multiple devices
- [ ] Upload to Google Play Console
- [ ] Configure app signing

#### iOS Release
- [ ] Configure provisioning profiles
- [ ] Test on physical devices
- [ ] Upload to App Store Connect
- [ ] Configure app review information

#### Web Release
- [ ] Build optimized web assets
- [ ] Configure hosting (Firebase, Netlify, etc.)
- [ ] Set up custom domain
- [ ] Configure HTTPS

---

## 15. Troubleshooting

### Common Issues & Solutions

#### App Won't Start / Blank Screen

**Symptoms**: App launches but shows blank/white screen
**Solutions**:
```bash
# Check environment variables
cat .env
# Ensure all required keys are present and valid

# Clear Flutter cache
flutter clean
flutter pub get

# Check for build errors
flutter doctor -v
```

**Common Causes**:
- Missing or invalid Supabase URL/keys
- Network connectivity issues
- Build cache corruption

#### Location Services Not Working

**Symptoms**: Location permission denied, GPS not working
**Solutions**:
```bash
# Android: Check permissions in AndroidManifest.xml
# iOS: Check Info.plist for location usage descriptions

# Test location services
flutter run --verbose
# Look for location permission prompts
```

**Platform-Specific**:
- **Android**: Enable location in device settings
- **iOS**: Grant location permission when prompted
- **Web**: Use HTTPS (required for geolocation API)

#### Stripe Payment Issues

**Symptoms**: Payment fails, Stripe errors
**Solutions**:
```bash
# Verify Stripe keys
echo $STRIPE_PUBLISHABLE_KEY

# Check Stripe dashboard for webhook configuration
# Ensure test/live keys match environment
```

**Common Issues**:
- Wrong Stripe key (test vs live)
- Missing webhook endpoints
- Network connectivity to Stripe API

#### Google Maps Not Loading

**Symptoms**: Maps show blank tiles or error
**Solutions**:
```bash
# Verify Google Maps API key
echo $GOOGLE_MAPS_API_KEY

# Check API key restrictions in Google Cloud Console
# Ensure Maps SDK is enabled
```

**API Key Requirements**:
- Enable Maps SDK for Android/iOS
- Enable Places API
- Enable Directions API
- Configure API key restrictions

#### Build Failures

**Android Build Issues**:
```bash
# Clean and rebuild
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
flutter build apk

# Check Java version
java -version
# Should be Java 11 or higher
```

**iOS Build Issues**:
```bash
# Update pods
cd ios && pod install && cd ..

# Check Xcode version
xcodebuild -version

# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
```

**Web Build Issues**:
```bash
# Clear web cache
flutter clean
flutter build web --web-renderer html

# Check browser console for errors
```

#### Admin Web Issues

**Blank Admin Dashboard**:
```bash
# Check environment variables
cd admin_web
cat .env

# Verify Supabase connection
npm run dev
# Check browser console for errors
```

**Build Failures**:
```bash
# Clear node modules
rm -rf node_modules package-lock.json
npm install

# Check Node.js version
node --version
# Should be 18 or higher
```

### Debug Commands

#### Flutter Debugging
```bash
# Verbose logging
flutter run --verbose

# Check dependencies
flutter pub deps

# Analyze code
flutter analyze

# Test coverage
flutter test --coverage
```

#### Admin Web Debugging
```bash
# Development with debug info
cd admin_web
npm run dev

# Check build output
npm run build
npm run preview
```

### Performance Issues

#### Slow App Performance
- Check for memory leaks in location services
- Optimize image assets
- Use `flutter build apk --split-per-abi` for smaller APKs

#### Slow Admin Dashboard
- Check Supabase query performance
- Implement pagination for large datasets
- Use React.memo for component optimization

### Platform-Specific Issues

#### Android
- **Min SDK**: Ensure target device meets minimum requirements
- **Permissions**: Check AndroidManifest.xml permissions
- **Signing**: Verify keystore configuration for release builds

#### iOS
- **Provisioning**: Check provisioning profiles
- **Capabilities**: Verify required capabilities in Xcode
- **App Store**: Ensure compliance with App Store guidelines

#### Web
- **HTTPS**: Required for geolocation and secure contexts
- **CORS**: Configure CORS for API calls
- **PWA**: Check manifest.json and service worker

### Getting Help

#### Logs and Diagnostics
```bash
# Flutter logs
flutter logs

# Android logs
adb logcat

# iOS logs
# Use Xcode console or device logs
```

#### Community Support
- **Flutter**: [Flutter.dev documentation](https://flutter.dev/docs)
- **Supabase**: [Supabase documentation](https://supabase.com/docs)
- **Stripe**: [Stripe documentation](https://stripe.com/docs)
- **Google Maps**: [Google Maps documentation](https://developers.google.com/maps/documentation)

---

## 16. Security & Extending

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
- **Environment Variables**: Never commit API keys to version control
- **HTTPS Only**: Enforce HTTPS for all API calls
- **Rate Limiting**: Implement rate limiting for sensitive endpoints
- **Input Validation**: Validate all user inputs server-side

#### Payment Security
- **PCI Compliance**: Use Stripe for payment processing (PCI DSS compliant)
- **Webhook Verification**: Verify Stripe webhook signatures
- **Secure Storage**: Never store payment details locally

### Extending the Application

#### Adding New Features

**Driver Management System**:
```sql
-- Add driver-specific tables
CREATE TABLE drivers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id),
  license_number text,
  vehicle_info jsonb,
  status text DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE vehicles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id uuid REFERENCES drivers(id),
  make text,
  model text,
  year integer,
  capacity integer,
  features jsonb
);
```

**Real-time Notifications**:
```dart
// Add to pubspec.yaml
dependencies:
  firebase_messaging: ^14.7.10
  flutter_local_notifications: ^16.3.2

// Implement push notifications
class NotificationService {
  static Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission();
    // Configure notification channels
  }
}
```

**Advanced Analytics**:
```dart
// Add analytics package
dependencies:
  firebase_analytics: ^10.7.4

// Track user events
FirebaseAnalytics.instance.logEvent(
  name: 'trip_booked',
  parameters: {
    'trip_id': tripId,
    'price': price,
    'distance': distance,
  },
);
```

#### Database Extensions

**Seat Management**:
```sql
-- Add seat selection system
CREATE TABLE seat_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid REFERENCES bookings(id),
  seat_number integer,
  passenger_name text,
  created_at timestamptz DEFAULT now()
);

-- Add seat map to trips
ALTER TABLE trips ADD COLUMN seat_map jsonb;
```

**Route Optimization**:
```sql
-- Add route waypoints
CREATE TABLE route_waypoints (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id uuid REFERENCES trips(id),
  sequence_order integer,
  location_name text,
  coordinates point,
  pickup_time timestamptz
);
```

#### Admin Dashboard Extensions

**Advanced Analytics Dashboard**:
```typescript
// Add chart libraries
npm install recharts @types/recharts

// Create analytics components
interface AnalyticsData {
  totalTrips: number;
  revenue: number;
  activeUsers: number;
  completionRate: number;
}
```

**Real-time Monitoring**:
```typescript
// Add real-time subscriptions
const { data, error } = supabase
  .channel('bookings')
  .on('postgres_changes', 
    { event: 'INSERT', schema: 'public', table: 'bookings' },
    (payload) => {
      // Update dashboard in real-time
      updateBookingsList(payload.new);
    }
  )
  .subscribe();
```

### Performance Optimization

#### Database Optimization
```sql
-- Add indexes for better performance
CREATE INDEX idx_trips_depart_time ON trips(depart_time);
CREATE INDEX idx_bookings_user_status ON bookings(user_id, status);
CREATE INDEX idx_location_history_user ON location_history(user_id);

-- Optimize queries with proper joins
SELECT t.*, COUNT(b.id) as booking_count
FROM trips t
LEFT JOIN bookings b ON t.id = b.trip_id
WHERE t.depart_time > NOW()
GROUP BY t.id;
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
// Implement local caching
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
- **Database**: Use Supabase production instance
- **CDN**: Configure CloudFlare for static assets
- **Monitoring**: Set up error tracking (Sentry)
- **Backups**: Configure automated database backups

#### Scaling Considerations
- **Database**: Implement read replicas for heavy queries
- **Caching**: Use Redis for session management
- **Load Balancing**: Configure multiple app instances
- **Monitoring**: Set up performance monitoring

### Contributing Guidelines

#### Code Standards
- Follow Flutter/Dart style guide
- Use meaningful variable names
- Add comprehensive comments
- Write unit tests for new features

#### Git Workflow
```bash
# Feature development
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

This comprehensive documentation covers every aspect of the Swift Ride project, from initial setup to advanced extensions. The project includes:

- **22 Flutter screens** with complete user flows
- **16 reusable widgets** for consistent UI
- **8 admin web pages** for management
- **Multi-platform support** (Android, iOS, Web, Desktop)
- **Complete backend integration** with Supabase
- **Payment processing** with Stripe
- **Location services** with Google Maps
- **Security best practices** and deployment strategies

For any specific implementation details, refer to the corresponding source files in the project structure. This documentation serves as a complete guide for development, deployment, and maintenance of the Swift Ride application.

---

For any screen/page, see the corresponding file for full implementation details. This guide lists every screen and page in sequence, with names and purposes, for both the Flutter app and admin web.

## Core Dependencies

- `supabase_flutter`: Supabase client (auth, database, storage)
- `flutter_dotenv`: Environment variables loader (.env)
- `flutter_stripe`: Stripe integration for payments
- `google_maps_flutter`, `geolocator`, `geocoding`, `flutter_polyline_points`: Maps & location
- `image_picker`: Media capture
- `intl`, `timezone`: Formatting & time
- `shared_preferences`: Local key-value storage

Refer to `pubspec.yaml` for the full list and versions.

## App Initialization Flow

```startLine:endLine:lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:swift_ride/Screens/SplashScreen.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  final envSupabaseUrl = dotenv.env['SUPABASE_URL'] ?? supabaseUrl;
  final envSupabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? supabaseKey;
  final stripeKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  if (stripeKey.isNotEmpty) {
    Stripe.publishableKey = stripeKey;
  }
  await Supabase.initialize(url: envSupabaseUrl, anonKey: envSupabaseKey);

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}
```

Key points:

- `.env` is loaded at runtime; Supabase and Stripe are initialized before `runApp`.
- Replace `SplashScreen` to change initial navigation.

## Supabase Integration

- The app initializes a global Supabase client via `Supabase.initialize` in `main.dart`.
- Access the client anywhere via `Supabase.instance.client`.

### Example: Creating a Trip Record

Below is a minimal example showing how to insert a trip record. Adjust fields to match your Supabase schema.

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

### Suggested `trips` Table (Supabase SQL)

Use Supabase SQL editor to create a compatible table:

```sql
create table if not exists public.trips (
  id uuid primary key default gen_random_uuid(),
  from_city text not null,
  to_city text not null,
  depart_time timestamptz not null,
  arrive_time timestamptz not null,
  price numeric not null,
  total_seats int not null,
  created_at timestamptz not null default now()
);
create index if not exists trips_depart_time_idx on public.trips(depart_time);
```

## Feature Overview

### Screens (high-level)

- `SplashScreen`: initial loading and app bootstrapping
- `OnBoardingScreen`: onboarding flow
- `SignInScreen`, `SignUpScreen`: authentication UI
- `HomeScreen`: main entry after auth
- `TripSelectionScreen`: choose or configure a trip
- `HistoryScreen`: user trip history
- `WalletScreen`: payment/wallet interface
- `BecomeDriverScreen`: driver onboarding/start
- Additional screens for profile, settings, location permissions, and legal pages

### Widgets (reusable)

- `BookingWidget`: booking UI elements
- `CustomTextField`, `PasswordFields`: form inputs
- `MainButton`, `custom_button`: CTA buttons
- `LoadingDialog`: global loading overlay
- `theme.dart`: color palette and styling helpers

## Building & Release

Android:

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

iOS:

```bash
cd ios && pod install && cd ..
flutter build ios --release
```

Web (optional):

```bash
flutter build web
```

## Troubleshooting

- Blank screen: ensure `.env` has `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
- Location issues: verify platform permissions for `geolocator`.
- Stripe errors: check publishable key and capability settings.
- Asset not found: confirm `pubspec.yaml` assets paths and run `flutter pub get`.

## Contributing

- Follow the existing code style and widget patterns.
- Keep dependencies updated in `pubspec.yaml`.

---

If you need deeper guidance for any specific screen/flow, ask and I’ll add a focused section.

## Data Model and Database Logic

This app uses Supabase (Postgres + RLS). Based on current code usage, these tables and functions are expected:

- `profiles`

  - `id uuid primary key` (matches `auth.users.id`)
  - `name text`
  - `wallet_balance numeric default 0`
  - `updated_at timestamptz default now()`
  - Used in `HomeScreen` to display name and in `WalletScreen` to read balance.

- `location_history`

  - `id uuid primary key default gen_random_uuid()`
  - `user_id uuid references auth.users(id)`
  - `address text`
  - `inserted_at timestamptz default now()`
  - Logic: when user selects a location, an entry is inserted or its `inserted_at` is updated; list is limited or toggled via “View All”.

- `trips`

  - `id uuid primary key default gen_random_uuid()`
  - `from_city text not null`
  - `to_city text not null`
  - `depart_time timestamptz not null`
  - `arrive_time timestamptz not null`
  - `price numeric not null`
  - `total_seats int not null`
  - Optional UI fields the app reads if present: `distance_text text`, `duration_text text`, `type text`, `ac boolean`
  - Logic: queried in `TripSelectionScreen` for both directions (A→B and B→A), grouped by next 7 days and filtered for “Today” to future times.

- `bookings`

  - Suggested fields (inferred from UI):
    - `id uuid primary key default gen_random_uuid()`
    - `user_id uuid references auth.users(id)`
    - `from_city text`, `to_city text`
    - `seats int`
    - `total_price numeric`
    - `status text` (e.g., pending, confirmed, completed, cancelled)
    - `created_at timestamptz default now()`
  - Logic: `HomeScreen` reads completed bookings for the current user to show history.

- RPCs / Edge Functions
  - Edge function `create-payment-intent` (called by mobile app) returns Stripe PaymentIntent client secret.
  - RPC `increment_wallet(user_id uuid, amount numeric)` increments `profiles.wallet_balance` server-side after Stripe payment.

RLS: Start permissive for prototyping; restrict by `auth.uid()` in production.

## Maps and Routing

The app uses Google Maps and Directions to show a route and booking card.

- Packages: `google_maps_flutter`, `google_maps_webservice`, `flutter_polyline_points`, `geocoding`, `geolocator`.
- Env: `GOOGLE_MAPS_API_KEY` must be set in `.env`.
- Flow in `DirectionsMapScreen`:
  1. Geocode `from`/`to` addresses to coordinates (or use current device location for “current location”).
  2. Fetch route via Google Directions API, decode polyline, render on `GoogleMap` with custom pickup/dropoff markers.
  3. Display `BookingWidget` over the map to proceed with seat selection/payment.

```startLine:endLine:lib/Screens/DirectionsMapScreen.dart
final directions = gmw.GoogleMapsDirections(
  apiKey: dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '',
);
...
final response = await directions.directionsWithLocation(
  gmw.Location(lat: fromLatLng!.latitude, lng: fromLatLng!.longitude),
  gmw.Location(lat: toLatLng!.latitude, lng: toLatLng!.longitude),
);
```

## Wallet Integration (Stripe + Supabase)

- Env: `STRIPE_PUBLISHABLE_KEY` in `.env`.
- Payment flow (in `WalletScreen`):
  1. Validate amount (min Rs 500 in current UI).
  2. Call Supabase Edge Function `create-payment-intent` with bearer token.
  3. Initialize and present Stripe PaymentSheet using returned client secret.
  4. On success, call Supabase RPC `increment_wallet` to update `profiles.wallet_balance`.
  5. Refresh balance from `profiles`.

```startLine:endLine:lib/Screens/WalletScreen.dart
final url = Uri.parse('$baseUrl/functions/v1/create-payment-intent');
final response = await http.post(
  url,
  headers: {
    'Authorization': 'Bearer ${supabase.auth.currentSession?.accessToken ?? ''}',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({'amount': enteredAmount}),
);
```

Server-side stubs (Supabase):

- Edge function `create-payment-intent`: creates PaymentIntent and returns `clientSecret`.
- RPC `increment_wallet`: SQL to increment the balance safely within a transaction.

## Screen-by-Screen Summary

- `SplashScreen`

  - Animations → checks connectivity → first-time flag → auth state → location permission → routes to appropriate screen.
  - Uses `shared_preferences`, `connectivity_plus`, `geolocator`, and Supabase auth state.

- `WelcomeScreen` / `EnableLocationScreen`

  - Entry for new or logged-out users; handles location permissions if needed.

- `OnBoardingScreen`

  - First-time user experience.

- `SignInScreen` / `SignUpScreen`

  - Authentication UI (Supabase auth integration assumed).

- `HomeScreen`

  - Greets user; loads `profiles.name`, recent `location_history`, and completed `bookings` for the user.
  - Allows quick navigation to `LocationSelectionScreen` and clearing specific history entries.

- `LocationSelectionScreen`

  - Lets user search/select an address; persists selection into `location_history`.

- `TripSelectionScreen`

  - Fetches two-way `trips` (A→B and B→A), organizes by next 7 days.
  - Filters “Today” to future departures only (local timezone PKT in code).
  - Taps into `DirectionsMapScreen` with selected trip.

- `DirectionsMapScreen`

  - Renders Google Map with polyline route and markers; overlays booking UI (`BookingWidget`).

- `WalletScreen`

  - Stripe PaymentSheet flow; updates wallet via Supabase RPC.

- `SettingsScreen`, `UserProfileScreen`, `HistoryScreen`, `AccountActionsScreen`, etc.
  - Standard profile/history/settings experiences; follow patterns in `HomeScreen` for data access.

## Extending the Data Model

Common additions:

- Add `status` to `trips` or `bookings` (draft/published/cancelled/completed).
- Add `drivers`, `vans`, `trip_assignments` for dispatch workflows.
- Add `bookings.seat_map jsonb` for per-seat selection.

Example constraints and indexes:

```sql
alter table public.bookings
  add constraint bookings_user_fk foreign key (user_id) references auth.users(id);
create index if not exists bookings_user_idx on public.bookings(user_id);
create index if not exists trips_route_time_idx on public.trips(from_city, to_city, depart_time);
```

## Security Notes

- Enable RLS on all tables; restrict reads/writes by `auth.uid()` where appropriate.
- Use Edge Functions or Postgres RPCs for sensitive operations (payments, wallet mutation).

## Admin Web (overview)

Note: The `admin_web` folder is currently removed. This section documents the intended Admin Web app so you can recreate it quickly and connect to the same Supabase backend as the Flutter app.

### Stack

- React + TypeScript + Vite
- `@supabase/supabase-js` client

### Environment

- Create `admin_web/.env` with:

```
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Client creation (example)

```ts
import { createClient } from "@supabase/supabase-js";
const client = createClient(
  import.meta.env.VITE_SUPABASE_URL!,
  import.meta.env.VITE_SUPABASE_ANON_KEY!
);
```

### Routing/pages (intended)

- Dashboard: overall KPIs
- Trips: list trips, create/edit/delete. Supports search by `from_city`/`to_city` and sort by `depart_time`.
  - Insert adds a row to Supabase `trips` table used by the Flutter app.
  - Search: `or(from_city.ilike.%q%,to_city.ilike.%q%)` with debounce.
- Drivers: manage driver records
- DriverDetail: view a specific driver by id
- Users: manage end users
- Payments: monitor and reconcile wallet top-ups
- Bookings: manage customer bookings

### Data contract shared with Flutter

- Writes to and reads from the same `trips`, `bookings`, and auxiliary tables described above. Creating a trip in Admin makes it visible in the app’s `TripSelectionScreen` immediately.

---

## Full Screen Reference (Flutter)

Below is a concise inventory of all screens under `lib/Screens` with their role and key logic. Use this as a map to the codebase.

- `AccountActionsScreen.dart`

  - Entry to account-related flows (profile, password, logout shortcuts).

- `BecomeDriverScreen.dart`

  - Driver onboarding entry. Typically collects driver info/documents before enabling driver features.

- `ContactUsScreen.dart`

  - Static contact/help information, potentially with mail/tap-to-call actions.

- `DirectionsMapScreen.dart`

  - Renders Google Map route between selected addresses.
  - Geocodes addresses, fetches Google Directions, decodes polylines, shows pickup/dropoff markers.
  - Overlays `BookingWidget` to proceed with booking/payment.

- `EnableLocationScreen.dart`

  - Guides user to enable location services and grant permissions (uses `geolocator`).

- `ForgotPasswordScreen.dart`

  - Password reset flow via Supabase auth (email-based in typical setups).

- `HistoryScreen.dart`

  - Displays user’s past rides; reads from `bookings` where `status = 'completed'`.

- `HomeScreen.dart`

  - Loads `profiles.name`, recent `location_history`, and completed `bookings` via Supabase.
  - Quick address entry opens `LocationSelectionScreen`; chips for recent history provide shortcuts.
  - Handles logout and drawer-driven navigation.

- `LocationSelectionScreen.dart`

  - Search/address entry UI. On selection, persists into `location_history` (dedupe + timestamp bump).

- `OnBoardingScreen.dart`

  - First-time experience; set by `SplashScreen` using a `SharedPreferences` flag.

- `PhoneNumberSignUpScreen.dart`

  - Phone-number-based registration UX (UI scaffolding; wire to Supabase OTP if required).

- `PrivacyPolicyScreen.dart`

  - Static legal content display.

- `SetLocationMapScreen.dart`

  - Map-based picker allowing the user to select/set a location.

- `SettingsScreen.dart`

  - App preferences; could include theme, notifications, and privacy.

- `SignInScreen.dart`

  - User login UI wired to Supabase auth.

- `SignUpScreen.dart`

  - Registration UI wired to Supabase auth.

- `SplashScreen.dart`

  - Animated splash. Connectivity check, first-run detection, auth-state check, and location permission routing.

- `TermsAndConditionsScreen.dart`

  - Static legal content display.

- `TripSelectionScreen.dart`

  - Fetches `trips` for both directions (A→B and B→A), grouped for the next 7 days.
  - For Today, filters out departures earlier than now; formats times; shows price, seats, distance/duration fields if provided.
  - Navigates to `DirectionsMapScreen` with selected trip.

- `UserProfileScreen.dart`

  - Shows and edits user profile info stored in `profiles`.

- `WalletScreen.dart`

  - Stripe PaymentSheet top-up; on success, calls Supabase RPC to increment wallet and refreshes balance.

- `WelcomeScreen.dart`
  - Landing for unauthenticated users; routes to sign-in or location permission flow as needed.
