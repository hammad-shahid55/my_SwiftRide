## Swift Ride — Flutter App

Swift Ride is a Flutter application for ride booking and management, integrated with Supabase for backend data and Flutter Stripe for payments. This document explains setup, configuration, architecture, and how to work with the codebase end-to-end.

### Contents
- Prerequisites
- Quick Start
- Environment Variables
- Project Structure
- Core Dependencies
- App Initialization Flow
- Supabase Integration
- Feature Overview (Screens & Widgets)
- Building & Release
- Troubleshooting

## Prerequisites
- Flutter SDK (3.7+ per `environment.skd`)
- Dart SDK (bundled with Flutter)
- Android Studio / Xcode for native builds
- A Supabase project (URL + anon key)
- Stripe account (optional, only if payments are enabled)

## Quick Start
```bash
# 1) Install dependencies
flutter pub get

# 2) Create .env file at project root (see Environment Variables below)

# 3) Run on device or emulator
flutter run
```

## Environment Variables
Create a `.env` file at the project root with the following keys:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key   # optional
```

Notes:
- The app also supports compile-time env via `--dart-define` as a fallback for `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
- Do not commit real keys to source control.

## Project Structure
```
lib/
  main.dart                      # App bootstrap, loads .env, initializes Supabase & Stripe
  Screens/                       # All feature screens (navigation targets)
    SplashScreen.dart            # Initial splash/loading
    OnBoardingScreen.dart        # App onboarding
    SignInScreen.dart            # Auth flows (example)
    SignUpScreen.dart
    HomeScreen.dart
    TripSelectionScreen.dart     # Trip selection UX
    HistoryScreen.dart           # User history
    WalletScreen.dart            # Wallet/Payments (Stripe-capable)
    BecomeDriverScreen.dart      # Driver onboarding entrypoint
    ... (see folder for full list)
  Widgets/                       # Reusable UI components
    theme.dart                   # Theme and styles
    BookingWidget.dart           # Booking specific UI
    CustomTextField.dart         # Form fields and inputs
    LoadingDialog.dart           # Loading overlays
    ...
assets/                          # Images, map styles, fonts declared in pubspec
```

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
  1) Geocode `from`/`to` addresses to coordinates (or use current device location for “current location”).
  2) Fetch route via Google Directions API, decode polyline, render on `GoogleMap` with custom pickup/dropoff markers.
  3) Display `BookingWidget` over the map to proceed with seat selection/payment.

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
  1) Validate amount (min Rs 500 in current UI).
  2) Call Supabase Edge Function `create-payment-intent` with bearer token.
  3) Initialize and present Stripe PaymentSheet using returned client secret.
  4) On success, call Supabase RPC `increment_wallet` to update `profiles.wallet_balance`.
  5) Refresh balance from `profiles`.

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
import { createClient } from '@supabase/supabase-js';
const client = createClient(import.meta.env.VITE_SUPABASE_URL!, import.meta.env.VITE_SUPABASE_ANON_KEY!);
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
