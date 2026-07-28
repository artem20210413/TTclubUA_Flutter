# Implementation Plan: City Users Map Screen

**Branch**: `001-city-users-map` | **Date**: 2026-07-26 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-city-users-map/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command; its definition describes the execution workflow.

## Summary

Add a new Flutter screen showing a map of cities where club members are located. On iOS the map renders via native Apple Maps (`apple_maps_flutter`); on Android via `flutter_map` with OpenStreetMap tiles (fully free, no API key/billing). Both platforms use the same custom Flutter-widget marker (avatar-in-circle or count badge) rendered as a platform-appropriate annotation/marker overlay, so the visual result is identical even though the two map engines wire markers up differently under the hood. The screen requests location permission via `geolocator`, centers the camera on the user (zoom 6.0) or falls back to Kyiv, loads city marker data from `GET api/cities/map`, and opens a paginated bottom sheet (`GET api/cities/{id}/users`) on marker tap, whose rows navigate to the existing `Profile` screen. Native on-screen zoom +/- and "my location" controls are added per-platform using each engine's own camera API.

## Technical Context

**Language/Version**: Dart (SDK `^3.5.4`, per `pubspec.yaml`), Flutter stable

**Primary Dependencies**: `apple_maps_flutter` (iOS native map), `flutter_map` + `latlong2` (Android map, OSM tiles), `geolocator` (location permission + position), `cached_network_image` (avatar caching) — all new additions to `pubspec.yaml`; existing `http` package reused for API calls per project convention (see research.md)

**Storage**: N/A — no local persistence beyond in-memory/image-cache state; all city/user data is fetched live from the existing backend API

**Testing**: `flutter_test` (existing `dev_dependency`); manual verification via `quickstart.md` since the project has no existing widget/integration test suite for comparable screens

**Target Platform**: iOS (native Apple Maps) and Android (flutter_map/OSM) mobile app screens, added to the existing Flutter app

**Project Type**: Mobile app (single Flutter codebase, platform-conditional map widget)

**Performance Goals**: Map screen interactive (markers visible) within ~2s on a warm app start under normal network conditions; marker/list avatar images that were already viewed in-session must not re-download (perceived-instant redisplay)

**Constraints**: Must reuse `TTScaffold` and `TTNeumorphicBox` for screen chrome/marker or list-row styling; must follow the existing manual-DTO (`XxxDto.fromJson`/`toJson`) convention under `lib/api/routs/Dto/City/`; must not introduce a new API client abstraction — follow the existing per-domain function style under `lib/api/routs/<domain>/`; Android map engine must be free/no-API-key (ruled out `google_maps_flutter` for that reason)

**Scale/Scope**: 1 new screen, 2 new DTOs (city map point, city member), 1 new bottom sheet component, 2 new API-call functions, platform-conditional marker rendering for 2 map engines

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

`.specify/memory/constitution.md` is still the unfilled template (all principles are placeholders, not yet ratified for this project) — there are no concrete gates to evaluate against. Proceeding without constitution gates; no violations to justify.

*Post-Phase-1 re-check*: No change — constitution remains unratified, no gates introduced by the Phase 1 design (DTOs, contracts, quickstart) that would require re-evaluation.

## Project Structure

### Documentation (this feature)

```text
specs/001-city-users-map/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

This is a single-codebase Flutter mobile app (not a web/backend split); the feature adds files into the existing `lib/` tree following current conventions (flat `pages/`, per-domain `api/routs/<domain>/`, shared `components/`).

```text
lib/
├── api/
│   └── routs/
│       ├── Dto/
│       │   └── City/
│       │       ├── CityDto.dart              # existing
│       │       ├── CityMapPointDto.dart       # NEW - GET api/cities/map item
│       │       └── CityMemberDto.dart         # NEW - GET api/cities/{id}/users item
│       └── cities/
│           └── CityServices.dart              # existing file; ADD fetchCityMapPoints(), fetchCityMembers(cityId, page)
├── components/
│   ├── TTScaffold.dart                        # existing, reused as-is
│   ├── TTNeumorphicBox.dart                    # existing, reused for marker badge / bottom sheet chrome
│   └── map/
│       ├── CityMapMarker.dart                  # NEW - shared avatar/count marker widget (used by both platforms)
│       └── CityMembersBottomSheet.dart         # NEW - paginated member list bottom sheet
└── pages/
    └── Nav/
        └── Map/
            ├── CityUsersMapScreen.dart         # NEW - screen entry point, uses TTScaffold
            ├── CityUsersMapScreen.ios.dart      # NEW - apple_maps_flutter implementation (conditional import)
            └── CityUsersMapScreen.android.dart  # NEW - flutter_map/OSM implementation (conditional import)

test/
└── (manual verification only for this feature — see quickstart.md; no existing
    widget/integration test harness for comparable screens to extend)
```

**Structure Decision**: Single Flutter project (existing `lib/` tree). Platform-specific map engines are isolated behind one screen entry point (`CityUsersMapScreen.dart`) that conditionally builds the iOS or Android implementation file (via `dart:io Platform.isIOS`/`isAndroid`, consistent with how the rest of the app already branches for platform-specific behavior), so the rest of the app (navigation, DTOs, bottom sheet, Profile screen) is platform-agnostic and shared.

## Complexity Tracking

> No constitution gates are defined yet (template unfilled), so no violations to justify. The one deliberate complexity trade-off — two map engines instead of one — is inherent to the explicit requirement (native Apple Maps on iOS, free engine on Android) and is contained entirely within the two `CityUsersMapScreen.*.dart` files; everything else in the feature (DTOs, API calls, bottom sheet, marker widget contract) is shared.
