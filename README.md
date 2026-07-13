# Cancha Mobile

## Overview

Cancha Mobile is a Flutter application for discovering sports venues, exploring available courts and schedules, and managing bookings. It provides the player-facing experience for the Cancha platform across Android, iOS, and the web.

## Features

- User registration, authentication, password recovery, and profile management
- Sports venue discovery with location and image information
- Court browsing by venue, sport, availability, and price
- Booking creation, cancellation, and calendar history
- Interactive maps and route information
- Custom themes and Premium-specific options
- Native splash screens and application icons
- Simplified wearable experience

## Tech Stack

- Flutter and Dart
- Provider for state management
- HTTP for backend communication
- Shared Preferences for local persistence
- Flutter Map, LatLong2, and Geolocator for maps and location
- Flutter Native Splash and Flutter Launcher Icons for native assets

## Project Structure

```text
lib/
  config/       Application configuration
  model/        Domain models
  services/     API client and integrations
  theme/        Themes and theme state
  utils/        Shared utilities
  view/         Application screens
  viewmodel/    Presentation logic and API coordination
```

## Requirements

- Flutter SDK with support for Dart `^3.11.1`
- Android Studio for Android development or Xcode for iOS development
- A running Cancha backend instance

## Configuration

The application uses `http://localhost:3000` on the web and `http://10.0.2.2:3000` on the Android emulator by default.

Set a different backend URL at compile time with `API_BASE_URL`:

```bash
flutter run --dart-define=API_BASE_URL=https://your-api.example.com
```

## Getting Started

```bash
git clone https://github.com/cancha-sports/mobile.git
cd mobile
flutter pub get
flutter run
```

## Available Commands

| Command | Description |
| --- | --- |
| `flutter run` | Run the application on a connected target |
| `flutter analyze` | Run static analysis |
| `flutter build apk --dart-define=API_BASE_URL=https://your-api.example.com` | Build an Android APK with a custom backend URL |
| `dart run flutter_native_splash:create` | Regenerate native splash assets |
| `dart run flutter_launcher_icons` | Regenerate application icons |

## Related Repository

- [Cancha Backend](https://github.com/cancha-sports/backend)
