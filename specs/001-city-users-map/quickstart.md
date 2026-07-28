# Quickstart: City Users Map Screen

Manual validation guide (no automated widget/integration test harness exists yet for a comparable screen — see `plan.md` Technical Context / `research.md` §5–8).

## Prerequisites

- Flutter SDK matching `pubspec.yaml` (`^3.5.4`).
- New dependencies added to `pubspec.yaml` and fetched: `apple_maps_flutter`, `flutter_map`, `latlong2`, `geolocator`, `cached_network_image` (see `research.md` §1, 3, 4).
- iOS: `NSLocationWhenInUseUsageDescription` added to `ios/Runner/Info.plist`.
- Android: `ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION` added to `android/app/src/main/AndroidManifest.xml`.
- A backend/test environment reachable by the app that serves `GET api/cities/map` and `GET api/cities/{id}/users` per `contracts/cities-map-api.md`, with at least one city that has `users_count == 1` with an avatar, one with `users_count > 1`, and one member with a missing/broken avatar (to exercise all marker/fallback states).

## Setup

```bash
flutter pub get
flutter run   # or: flutter run -d <ios-simulator-id> / -d <android-emulator-id>
```

Navigate to the new City Users Map screen from wherever it's wired into the app's navigation (per `tasks.md` for the actual entry point added).

## Validation scenarios

1. **Location permission granted**: On first open, accept the location permission prompt. Expected: camera centers on the simulator/emulator's mocked current location at zoom 6.0 (see platform tooling for setting a custom location).
2. **Location permission denied**: Deny the prompt (or run with location services off). Expected: camera centers on Kyiv (50.4501, 30.5234) at zoom 6.0.
3. **Single-member city with avatar**: Find/mock a city with `users_count == 1` and a working `avatar` URL. Expected: marker shows that member's avatar in a circle.
4. **Broken avatar fallback**: Mock a city with `users_count == 1` and an avatar URL that 404s. Expected: marker shows the default styled circle with "1".
5. **Multi-member city**: Find/mock a city with `users_count > 1`. Expected: marker shows the branded badge with the count.
6. **Map data load failure**: Simulate a network failure for `GET api/cities/map` (e.g. airplane mode before first load). Expected: non-blocking retry SnackBar appears; tapping Retry re-attempts the load; map remains visible/pannable underneath.
7. **Open member list**: Tap a marker with `users_count >= 1`. Expected: modal bottom sheet opens showing city name + total count header, then a loading state, then the first page of member rows (avatar, name, minor secondary info).
8. **Infinite scroll**: In a city with more members than one page, scroll the bottom sheet list to the bottom. Expected: next page loads and appends automatically, no manual "load more" tap needed.
9. **Member list load failure**: Simulate a network failure while a page is loading. Expected: non-blocking retry SnackBar scoped to the bottom sheet; existing rows remain visible; Retry re-attempts that page.
10. **Row → profile navigation**: Tap a member row in the bottom sheet. Expected: app navigates to the existing `Profile` screen (`lib/pages/Nav/Mention/Profile.dart`) for that member's `id`.
11. **Avatar caching**: Close and reopen the same city's bottom sheet (or revisit the map) within the same session. Expected: previously loaded avatars display instantly with no visible re-download/flicker.
12. **Native zoom controls**: Tap the on-screen "+" control; camera zooms in one native step. Tap "−"; camera zooms out one native step.
13. **My-location control**: Tap the "my location" control. Expected: camera animates to the device's current location. With location permission unavailable, expected: permission is (re-)requested or a non-blocking notice is shown; app does not crash or freeze.
14. **Cross-platform parity**: Repeat scenarios 3–5 and 12–13 on both an iOS simulator (Apple Maps) and an Android emulator (flutter_map/OSM). Expected: marker visuals and control behavior are equivalent even though the underlying map engines differ.

## Success

All 14 scenarios behave as described on both iOS and Android without crashes, and match the acceptance scenarios in `spec.md`.
