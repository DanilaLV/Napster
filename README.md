# Napster – Powernap Alarm MVP

Napster is a Flutter MVP designed for fast one-tap naps with reliable local alarms on Android and iOS. The focus is preset-driven naps, minimal UI, and Pro monetisation unlocking advanced timers and tones.

## Features

- Preset naps (10 / 25 / 45 / 90 minutes) with quick scheduling and confirmation toasts.
- Custom timer from 5–180 minutes (Pro unlocks >30 minutes).
- Active nap screen with countdown, wake time, cancel, and snooze.
- Local alarms using `flutter_local_notifications` backed by platform alarm APIs.
- Persistent foreground notification on Android when a nap is running.
- Settings for default preset, tone selection (5 bundled tones), vibration, snooze length, language (EN/LV), and time format.
- Paywall powered by `in_app_purchase` for Napster Pro unlock.
- About & privacy screen with mute limitation notice.
- Riverpod-based state management with shared preferences persistence.
- Timezone awareness via `timezone` package with Europe/Riga default.

## Project Structure

```
lib/
  app.dart                # MaterialApp + localization + initialization
  main.dart               # Entry point
  l10n/                   # English and Latvian translations
  features/
    home/                 # Home screen, presets, custom timer
    alarm/                # Alarm scheduling + active alarm UI
    settings/             # Settings, tone picker, about screen
    paywall/              # Paywall UI + IAP service
  shared/                 # Providers, theme, widgets, utilities
  data/                   # Models, persistence repository
android/                  # Native Android implementation (AlarmManager, receivers)
ios/                      # Native iOS implementation (UNNotification requests)
assets/                   # Placeholder audio + branding assets
```

## Getting Started

> **Prerequisite:** Flutter SDK 3.22+ with Dart 3.3+, Android Studio/Xcode configured, and CocoaPods for iOS.

1. Install Flutter dependencies:

   ```sh
   flutter pub get
   ```

2. Generate localization files (optional if you re-run Flutter toolchain):

   ```sh
   flutter gen-l10n
   ```

3. Android-specific setup:

   - Ensure the `SCHEDULE_EXACT_ALARM` permission is declared (already in `AndroidManifest.xml`).
   - If you cloned this repository without Gradle wrapper files, run inside `android/`:

     ```sh
     gradle wrapper --gradle-version 8.2
     ```

     This downloads the wrapper (network access required).

   - Build & run:

     ```sh
     flutter run -d android
     ```

4. iOS-specific setup:

   - From the `ios/` directory, install pods:

     ```sh
     pod install
     ```

   - Open `Runner.xcworkspace` in Xcode, configure signing, and run.

   > **Note:** iOS mute switch cannot be bypassed. The app raises best-effort scheduled notifications with sound while device is not muted.

5. Localisation toggle:

   - The settings screen allows switching between English and Latvian instantly.

## Alarm Behaviour

- **Android** uses `AlarmManager#setExactAndAllowWhileIdle` plus foreground service to keep a persistent notification and survive Doze/reboot (reschedule hook placeholder provided).
- **iOS** leverages `UNUserNotificationCenter` scheduled notifications with bundled tones (respecting the mute switch).

## Monetisation

- `Napster Pro` product id: `napster_pro_unlock` (one-time purchase).
- Update the product identifiers in App Store Connect / Google Play Console to match this ID.
- Restore purchases is wired via `InAppPurchase.restorePurchases`.

## Permissions UX

- Notification permission requested on first launch.
- Exact alarm permission triggers Android settings intent on Android 12+.
- Settings screen surfaces toggles and directs to system settings when denied.

## Testing

- Unit tests cover time utilities and settings serialization.
- Manual test checklist included below.

### Run Tests

```sh
flutter test
```

_(In this repository tests are provided, but running them requires Flutter tooling to be installed locally.)_

## Manual Test Checklist

- Start each preset and confirm wake-up time text.
- Kill the app and validate Android alarm / iOS notification still fires.
- Do Not Disturb mode: verify system-default behaviour.
- Change timezone while countdown is active and observe updated wake time.
- Reboot Android device with scheduled alarm (Boot receiver reschedule placeholder; ensure Flutter layer handles persistence on resume).
- Purchase Napster Pro, relaunch app, and restore purchases.
- Deny permissions and check inline prompts with links to system settings.
- Switch language to Latvian and verify all strings.
- Toggle vibration (Android) and confirm haptics.

## In-App Purchases Setup

1. **Google Play Console**
   - Create in-app product `napster_pro_unlock` (Managed product, €4.99 or your preferred price).
   - Add license testers for QA.
   - Use billing test accounts for development.

2. **App Store Connect**
   - Add non-consumable product with the same identifier.
   - Configure localised pricing and review information.
   - Enable StoreKit configuration for local testing if desired.

## Limitations & Notes

- Bundled audio assets are placeholders; replace with production-ready tone files before release.
- Android foreground service implementation is minimal and should be expanded for rich alarm UI.
- Boot receiver logs an event; ensure background isolate reschedules alarms from stored state on actual device testing.
- iOS critical alerts are not available for third-party apps. Wake reliability depends on notification permissions and device sound state.
- Exact alarm permission flow on Android 12+ depends on OEM behaviour; provide user guidance if system denies the request.

## Privacy

All data stays on-device via `SharedPreferences`. No analytics or remote services are bundled (hooks for privacy-friendly counters can be added later).

## License

MIT License © 2025 Napster MVP authors.
