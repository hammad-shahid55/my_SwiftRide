SwiftRide - Complete Ride Booking System

SwiftRide is a comprehensive cross-platform ride booking and management system built with Flutter and React, featuring real-time booking, payment processing, and automated email notifications.

## 🚀 Features

- **Cross-Platform Mobile App** (Flutter) - Android, iOS, Web, Desktop
- **Admin Web Dashboard** (React/TypeScript) - Complete management interface
- **Real-time Booking System** - Live trip availability and booking
- **Payment Integration** - Stripe-powered wallet and payments
- **Location Services** - Google Maps integration with route planning
- **Email Notifications** - Automated booking confirmations via Resend API
- **Multi-platform Support** - Android, iOS, Web, Windows, Linux, macOS

## 📱 Project Structure

```
my_SwiftRide/
├── lib/                          # Flutter app source
│   ├── main.dart                 # App entry point
│   ├── Screens/                  # 22 app screens
│   ├── Services/                 # 5 business logic services
│   └── Widgets/                  # 16 reusable UI components
├── admin_web/                   # React admin dashboard
│   ├── src/
│   │   ├── main.tsx            # Admin app entry
│   │   └── pages/              # 8 admin pages
│   └── package.json
├── assets/                      # Static resources
│   ├── fonts/                  # Custom fonts (4 families)
│   ├── images/                 # App images and icons
│   └── map_styles/             # Google Maps themes
├── android/                     # Android platform files
├── ios/                         # iOS platform files
├── web/                         # Web platform files
├── windows/                     # Windows platform files
├── linux/                       # Linux platform files
├── macos/                       # macOS platform files
├── pubspec.yaml                 # Flutter dependencies
└── README.md                    # This file
```

## 🛠️ Prerequisites

### Development Environment
- **Flutter SDK** 3.7+ with Dart SDK
- **Node.js** 18+ for admin web development
- **Git** for version control
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA

### Platform Requirements
- **Android**: Android Studio, Android SDK, Java 11+
- **iOS**: Xcode 14+, macOS, iOS Simulator
- **Web**: Modern browser with WebGL support

### External Services
- **Supabase Project** - Backend services (auth, database, storage)
- **Stripe Account** - Payment processing
- **Google Cloud Console** - Maps API and OAuth credentials
- **Resend Account** - Email notification service

## ⚡ Quick Start

### 1. Clone and Setup
```bash
git clone <repository-url>
cd my_SwiftRide

# Install Flutter dependencies
flutter pub get

# Install admin web dependencies
cd admin_web
npm install
cd ..
```

### 2. Environment Configuration
Create `.env` file in project root:
```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key

# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key

# Google Services
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
GOOGLE_SIGN_IN_CLIENT_ID=your_google_oauth_client_id

# Email Service (Resend)
RESEND_API_KEY=re_your_resend_api_key
RESEND_FROM_EMAIL=onboarding@resend.dev

# App Configuration
APP_NAME=SwiftRide
COMPANY_NAME=SwiftRide
SUPPORT_EMAIL=support@swiftride.com
```

Create `admin_web/.env`:
```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
VITE_GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

### 3. Run the Applications

**Flutter App:**
```bash
flutter run
```

**Admin Web:**
```bash
cd admin_web
npm run dev
```

## 📱 Flutter App Screens (22 Screens)

| Screen | Purpose |
|--------|---------|
| `SplashScreen.dart` | App initialization and routing |
| `OnBoardingScreen.dart` | First-time user introduction |
| `WelcomeScreen.dart` | Entry for unauthenticated users |
| `EnableLocationScreen.dart` | Location permission handling |
| `SignInScreen.dart` | User authentication |
| `SignUpScreen.dart` | New user registration |
| `PhoneNumberSignUpScreen.dart` | Phone-based registration |
| `ForgotPasswordScreen.dart` | Password reset |
| `HomeScreen.dart` | Main dashboard |
| `LocationSelectionScreen.dart` | Address selection and search |
| `SetLocationMapScreen.dart` | Map-based location picker |
| `TripSelectionScreen.dart` | Trip listing and selection |
| `DirectionsMapScreen.dart` | Route display and booking |
| `WalletScreen.dart` | Wallet management and payments |
| `HistoryScreen.dart` | Trip history display |
| `UserProfileScreen.dart` | User profile management |
| `SettingsScreen.dart` | App preferences |
| `AccountActionsScreen.dart` | Account management shortcuts |
| `BecomeDriverScreen.dart` | Driver onboarding |
| `ContactUsScreen.dart` | Support and contact information |
| `PrivacyPolicyScreen.dart` | Privacy policy display |
| `TermsAndConditionsScreen.dart` | Terms and conditions |

## 🎨 Reusable Widgets (16 Widgets)

| Widget | Purpose |
|--------|---------|
| `theme.dart` | App color palette and styling |
| `BookingWidget.dart` | Booking UI components |
| `CustomTextField.dart` | Form input fields |
| `PasswordFields.dart` | Password input fields |
| `MainButton.dart` | Primary action buttons |
| `custom_button.dart` | Secondary buttons |
| `LoadingDialog.dart` | Loading overlays |
| `GoogleButton.dart` | Google sign-in button |
| `CustomAppBar.dart` | App bar component |
| `CustomBackButton.dart` | Back navigation button |
| `CustomCheckbox.dart` | Checkbox UI |
| `CustomTextWidget.dart` | Text display component |
| `PrivacyTermsText.dart` | Legal text component |
| `BuildButton.dart` | Build/submit button |
| `OrDivider.dart` | Divider with "or" text |
| `app_drawer.dart` | Navigation drawer |

## 🔧 Business Services (5 Services)

| Service | Purpose |
|---------|---------|
| `EmailConfig.dart` | Email service configuration |
| `SimpleEmailService.dart` | Core email sending functionality |
| `EmailTestService.dart` | Email configuration testing |
| `BookingStatusService.dart` | Booking status management |
| `AutoCompletionService.dart` | Automatic ride completion |

## 🌐 Admin Web Pages (8 Pages)

| Page | Route | Purpose |
|------|-------|---------|
| `App.tsx` | `/` | Main layout and navigation |
| `Dashboard.tsx` | `/` | KPIs and analytics |
| `Trips.tsx` | `/trips` | Trip management |
| `Users.tsx` | `/users` | User management |
| `Drivers.tsx` | `/drivers` | Driver management |
| `DriverDetail.tsx` | `/drivers/:id` | Individual driver details |
| `Payments.tsx` | `/payments` | Payment monitoring |
| `Bookings.tsx` | `/bookings` | Booking management |

## 🗄️ Database Schema

### Core Tables
- **`profiles`** - User information and wallet balance
- **`trips`** - Available trips with routes and pricing
- **`bookings`** - User bookings with status tracking
- **`location_history`** - Recent user locations

### Key Features
- **Row Level Security (RLS)** - Secure data access
- **Real-time subscriptions** - Live updates
- **Edge Functions** - Server-side logic for payments
- **RPC Functions** - Database procedures for wallet operations

## 📧 Email Notification System

Automated email notifications powered by Resend API:

- **Booking Confirmations** - Trip details and confirmation
- **Booking Cancellations** - Cancellation confirmations with refund info
- **Ride Completions** - Automatic completion notifications
- **Complaint Confirmations** - Support ticket acknowledgments
- **Account Deletions** - Account deletion confirmations

## 🏗️ Building & Release

### Flutter Builds
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
cd ios && pod install && cd ..
flutter build ios --release
flutter build ipa --release

# Web
flutter build web --release

# Desktop
flutter build windows --release
flutter build linux --release
flutter build macos --release
```

### Admin Web Build
```bash
cd admin_web
npm run build
```

## 🧪 Testing

The project includes comprehensive testing:
- **Unit Tests** - Widget and service testing
- **Integration Tests** - End-to-end user flows
- **Email Tests** - Email service functionality

```bash
# Run all tests
flutter test

# Run specific test categories
flutter test test/widget_test/
flutter test test/unit_test/
flutter test integration_test/
```

## 🔧 Platform Configuration

### Android
- **Target SDK**: 36 (Android 15)
- **Min SDK**: Flutter default
- **Compile SDK**: 36
- **Java Version**: 11

### iOS
- **Bundle ID**: com.example.swift_ride
- **Display Name**: Swift Ride
- **Target**: iOS 12.0+

### Web
- **PWA Support** - Progressive Web App capabilities
- **HTTPS Required** - For geolocation and secure contexts

## 🚨 Troubleshooting

### Common Issues

**App won't start:**
- Check `.env` file has all required API keys
- Verify Supabase URL and keys are correct
- Run `flutter clean && flutter pub get`

**Location services not working:**
- Check platform permissions in AndroidManifest.xml (Android) or Info.plist (iOS)
- Ensure device location is enabled
- For web, ensure HTTPS is used

**Payment issues:**
- Verify Stripe keys are correct (test vs live)
- Check Stripe dashboard for webhook configuration
- Ensure network connectivity to Stripe API

**Email notifications not working:**
- Verify Resend API key is valid
- Check Resend dashboard for delivery status
- Ensure sender email domain is verified

**Google Maps not loading:**
- Verify Google Maps API key
- Check API key restrictions in Google Cloud Console
- Ensure required APIs are enabled (Maps SDK, Places API, Directions API)

## 📚 Dependencies

### Flutter Core Dependencies
- `supabase_flutter: ^2.9.1` - Backend services
- `flutter_stripe: ^11.5.0` - Payment processing
- `google_maps_flutter: ^2.12.3` - Maps integration
- `geolocator: ^14.0.2` - Location services
- `google_sign_in: ^7.1.0` - OAuth authentication
- `flutter_dotenv: ^6.0.0` - Environment variables

### Admin Web Dependencies
- `react: ^18.3.1` - UI framework
- `@supabase/supabase-js: ^2.45.4` - Backend client
- `react-router-dom: ^6.26.2` - Routing
- `vite: ^5.4.2` - Build tool

## 🔒 Security

- **Row Level Security (RLS)** enabled on all database tables
- **Environment variables** for sensitive configuration
- **HTTPS enforcement** for web builds
- **Input validation** on all user inputs
- **Secure payment processing** via Stripe

## 🚀 Deployment

### Production Checklist
- [ ] Update version numbers in `pubspec.yaml`
- [ ] Configure production API keys
- [ ] Set up Supabase production instance
- [ ] Configure Stripe webhooks
- [ ] Test on all target platforms
- [ ] Run security audit: `flutter pub audit`

### Hosting Options
- **Flutter Web**: Vercel, Netlify, Firebase Hosting
- **Admin Web**: Vercel, Netlify, GitHub Pages
- **Mobile Apps**: Google Play Store, Apple App Store

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -m "Add new feature"`
4. Push to branch: `git push origin feature/new-feature`
5. Submit a pull request

## 📞 Support

For support and questions:
- **Email**: support@swiftride.com
- **Documentation**: See inline code comments
- **Issues**: Create GitHub issues for bugs and feature requests

---

**SwiftRide** - Your complete ride booking solution 🚗✨