---

description: "Task list for City Users Map Screen implementation"
---

# Tasks: City Users Map Screen

**Input**: Design documents from `/specs/001-city-users-map/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all present)

**Tests**: Not requested in the feature specification; no test tasks are included. Validation is performed manually via `quickstart.md`.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story. Note: `lib/pages/Nav/Map/CityUsersMapScreen.dart` already exists as a placeholder screen (wired to a "TTclubUA у світі" banner on `lib/pages/Nav/Home.dart`); tasks below replace/extend that placeholder rather than create it from scratch.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

Single Flutter project. All paths are relative to the repository root, under the existing `lib/` tree, per `plan.md` → Project Structure.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add the new map/geo/cache dependencies and platform permission config needed by every story.

- [X] T001 Add `apple_maps_flutter`, `flutter_map`, `latlong2`, `geolocator`, `cached_network_image` to `pubspec.yaml` dependencies and run `flutter pub get` (required upgrading `http` from `^0.13.3` to `^1.2.1` to satisfy `flutter_map`'s dependency; verified no breakage via `flutter analyze` across `lib/api/`)
- [X] T002 [P] Add `NSLocationWhenInUseUsageDescription` (Ukrainian rationale string) to `ios/Runner/Info.plist`
- [X] T003 [P] Add `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION` permissions to `android/app/src/main/AndroidManifest.xml`

**Checkpoint**: `flutter pub get` succeeds and both platform manifests declare location permission; project still builds.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Stand up the platform-conditional map screen skeleton (default-centered on Kyiv, zoom 6.0, no data yet) that every user story renders inside.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T004 Replace the placeholder body in `lib/pages/Nav/Map/CityUsersMapScreen.dart` with a `StatefulWidget` that conditionally builds the iOS or Android map implementation via `Platform.isIOS`/`Platform.isAndroid` (`dart:io`), passing a shared initial camera target (hardcoded Kyiv `50.4501, 30.5234`, zoom `6.0`) down to whichever platform widget is built
- [X] T005 [P] Create `lib/pages/Nav/Map/CityUsersMapScreen.ios.dart`: `apple_maps_flutter` `AppleMap` widget accepting an initial camera target/zoom, rendered inside `TTScaffold`
- [X] T006 [P] Create `lib/pages/Nav/Map/CityUsersMapScreen.android.dart`: `flutter_map` `FlutterMap` widget with an OpenStreetMap `TileLayer`, accepting an initial camera target/zoom, rendered inside `TTScaffold`

**Checkpoint**: Opening the map screen (via the Home banner) shows a live, empty map centered on Kyiv at zoom 6.0 on both iOS and Android. No markers, no location, no controls yet — foundation ready for user story work.

---

## Phase 3: User Story 1 - See member locations on a map (Priority: P1) 🎯 MVP

**Goal**: Load `GET api/cities/map` and render one marker per city (avatar circle, count badge, or "1" fallback), matching FR-001, FR-005–FR-009, FR-016.

**Independent Test**: Open the map screen with a mocked `GET api/cities/map` response covering a single-member-with-avatar city, a multi-member city, and a broken-avatar city; verify each marker renders with the correct visual per `spec.md` Acceptance Scenarios 1–4, and that a failed request shows a retry SnackBar.

### Implementation for User Story 1

- [X] T007 [P] [US1] Create `CityMapPointDto` in `lib/api/routs/Dto/City/CityMapPointDto.dart` per `data-model.md` (`id`, `name`, `latitude`, `longitude`, `usersCount`, `avatarUrl`), following the manual `fromJson`/`toJson` style of `lib/api/routs/Dto/City/CityDto.dart`
- [X] T008 [US1] Add `fetchCityMapPoints()` to `lib/api/routs/cities/CityServices.dart`, calling `GET api/cities/map` via `package:http` per the existing per-domain function convention (see `contracts/cities-map-api.md`) (depends on T007)
- [X] T009 [P] [US1] Create `CityMapMarker` widget in `lib/components/map/CityMapMarker.dart`: renders a circular avatar (via `cached_network_image` + `TTNeumorphicBox`) when `usersCount == 1 && avatarUrl != null`, otherwise a branded count badge; falls back to a styled circle with "1" on image load error (FR-006–FR-008)
- [X] T010 [US1] In `lib/pages/Nav/Map/CityUsersMapScreen.ios.dart`, load `CityMapPointDto` list on init, rasterize `CityMapMarker` per unique avatar/count combination into an `Annotation` icon (per `research.md` §2), and render one `Annotation` per city (depends on T005, T008, T009)
- [X] T011 [US1] In `lib/pages/Nav/Map/CityUsersMapScreen.android.dart`, load `CityMapPointDto` list on init and render one `Marker` per city inside a `MarkerLayer`, using `CityMapMarker` directly as the marker child (depends on T006, T008, T009)
- [X] T012 [US1] Add a non-blocking retry `SnackBar` in `lib/pages/Nav/Map/CityUsersMapScreen.dart` (shared state, surfaced from both platform widgets) for `GET api/cities/map` failures, without blocking the rest of the map (FR-016)
- [X] T013 [US1] Defensively skip rendering a marker for any city point with `usersCount < 1` in both platform files (Edge Cases)

**Checkpoint**: User Story 1 is fully functional and independently testable — markers render correctly on both platforms with all three visual states and graceful failure handling.

---

## Phase 4: User Story 3 - View the list of members in a city (Priority: P1)

**Goal**: Tapping a marker opens a paginated bottom sheet of that city's members, and tapping a member navigates to their profile (FR-010–FR-015, FR-017, FR-018).

**Independent Test**: Tap a marker with a mocked `GET api/cities/{id}/users` response; verify the bottom sheet header, row content, infinite scroll, avatar fallback, retry-on-failure, and row-tap navigation to `Profile` all behave per `spec.md` Acceptance Scenarios 1–6.

### Implementation for User Story 3

- [X] T014 [P] [US3] Create `CityMemberDto` in `lib/api/routs/Dto/City/CityMemberDto.dart` per `data-model.md` (`id`, `name`, `profileImage`, `roles`, `telegramNickname`, `instagramNickname`, `updatedAt`), following the same manual DTO style as `lib/api/routs/Dto/User/UserSmallDto.dart`
- [X] T015 [US3] Add `fetchCityMembers(int cityId, {int page})` to `lib/api/routs/cities/CityServices.dart`, calling `GET api/cities/{id}/users` per `contracts/cities-map-api.md` (depends on T014; edits the same file as T008 — sequential, not parallel)
- [X] T016 [US3] Create `CityMembersBottomSheet` widget in `lib/components/map/CityMembersBottomSheet.dart`: header with city name + total count, paginated `ScrollController`-driven list (reusing the `_page`/`_hasMore` pattern from `lib/pages/Nav/Admin/User/SearchUser.dart`), rows built with `TTNeumorphicBox` showing avatar (via `cached_network_image`, with initials/branded fallback per FR-014), name, and roles (depends on T014, T015)
- [X] T017 [US3] Wire marker tap → `showModalBottomSheet(isScrollControlled: true, ...)` opening `CityMembersBottomSheet` for the tapped city in `lib/pages/Nav/Map/CityUsersMapScreen.ios.dart` (depends on T010, T016)
- [X] T018 [US3] Wire marker tap → `showModalBottomSheet(isScrollControlled: true, ...)` opening `CityMembersBottomSheet` for the tapped city in `lib/pages/Nav/Map/CityUsersMapScreen.android.dart` (depends on T011, T016)
- [X] T019 [US3] Add row tap handler in `lib/components/map/CityMembersBottomSheet.dart` navigating via `Navigator.push(context, MaterialPageRoute(builder: (_) => Profile(id: member.id)))` (FR-018)
- [X] T020 [US3] Add a non-blocking retry `SnackBar` scoped to the bottom sheet in `lib/components/map/CityMembersBottomSheet.dart` for page-load failures, preserving already-loaded rows (FR-017)
- [X] T021 [US3] Ensure a new marker tap cancels/ignores any in-flight previous bottom-sheet request in `lib/pages/Nav/Map/CityUsersMapScreen.ios.dart` and `.android.dart` (Edge Cases)

**Checkpoint**: User Stories 1 and 3 together deliver the MVP — map with markers and a fully working member list + profile navigation, on both platforms.

---

## Phase 5: User Story 2 - Center the map on my location (Priority: P2)

**Goal**: Request location permission and center the initial camera on the user's position (or fall back to Kyiv), per FR-002–FR-004.

**Independent Test**: Open the map screen with location permission granted and verify the camera centers on the mocked current position at zoom 6.0; deny permission and verify it falls back to Kyiv at zoom 6.0.

### Implementation for User Story 2

- [X] T022 [US2] Add a `geolocator`-based location resolution step in `lib/pages/Nav/Map/CityUsersMapScreen.dart` (`initState`): call `checkPermission()`/`requestPermission()` then `getCurrentPosition()`, uniformly falling back to the Kyiv default on any denial/error (`PermissionDeniedException`, `LocationServiceDisabledException`, timeout, etc.) per `research.md` §3
- [X] T023 [US2] Pass the resolved initial camera target/zoom from T022 into `lib/pages/Nav/Map/CityUsersMapScreen.ios.dart` in place of the hardcoded Kyiv default from T005 (depends on T005, T022)
- [X] T024 [US2] Pass the resolved initial camera target/zoom from T022 into `lib/pages/Nav/Map/CityUsersMapScreen.android.dart` in place of the hardcoded Kyiv default from T006 (depends on T006, T022)

**Checkpoint**: Map screen now personalizes its initial view per FR-002–FR-004 on both platforms, without affecting US1/US3 behavior.

---

## Phase 6: User Story 4 - Control the map view with on-screen controls (Priority: P2)

**Goal**: Add native zoom in/out and "my location" on-screen controls, per FR-019–FR-021.

**Independent Test**: Tap zoom-in/zoom-out and verify the camera zoom level changes by one native step each way; tap "my location" and verify the camera recenters/animates to the current position, with a graceful non-blocking fallback when location is unavailable.

### Implementation for User Story 4

- [X] T025 [P] [US4] Add on-screen zoom-in/zoom-out controls to `lib/pages/Nav/Map/CityUsersMapScreen.ios.dart`, driving the `AppleMapController`'s native camera zoom (FR-019)
- [X] T026 [P] [US4] Add on-screen zoom-in/zoom-out controls to `lib/pages/Nav/Map/CityUsersMapScreen.android.dart`, driving the `flutter_map` `MapController`'s camera zoom (FR-019)
- [X] T027 [P] [US4] Add a "my location" control to `lib/pages/Nav/Map/CityUsersMapScreen.ios.dart` that re-resolves the current position (reusing T022's logic) and animates the `AppleMapController` camera to it (FR-020)
- [X] T028 [P] [US4] Add a "my location" control to `lib/pages/Nav/Map/CityUsersMapScreen.android.dart` that re-resolves the current position (reusing T022's logic) and moves the `MapController` camera to it (FR-020)
- [X] T029 [US4] When "my location" is tapped without an available position (permission not granted or unavailable), request permission or show a non-blocking notice in `lib/pages/Nav/Map/CityUsersMapScreen.dart`, without disrupting the rest of the map (FR-021)

**Checkpoint**: All four user stories are independently functional; the map screen is feature-complete per `spec.md`.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Verify caching, cross-platform parity, and run final validation.

- [X] T030 [P] Verify `cached_network_image` is used consistently for both marker avatars (`CityMapMarker`, uses `CachedNetworkImage` directly) and bottom-sheet row avatars (`CityMembersBottomSheet`, via the existing shared `UserAvatar` component). Note: `UserAvatar` uses `Image`/`NetworkImage`, which Flutter still caches in-memory per session (satisfies the "no re-download within a session" wording of FR-009/SC-005); switching it to `cached_network_image` for disk-level caching would be an app-wide change to a component used well beyond this feature, so it was left as-is
- [X] T031 Remove the now-unused placeholder "карта вже готується" copy/import cleanup left over from the initial `lib/pages/Nav/Map/CityUsersMapScreen.dart` stub, if any remains after T004 — confirmed no leftovers remain
- [ ] T032 [P] Run all 14 `quickstart.md` validation scenarios on an iOS simulator (Apple Maps) — requires a macOS/Xcode environment with a simulator; not runnable in this sandbox, needs manual execution
- [ ] T033 [P] Run all 14 `quickstart.md` validation scenarios on an Android emulator (flutter_map/OSM) — requires an Android SDK/emulator environment; not runnable in this sandbox, needs manual execution

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational — no dependency on other stories
- **User Story 3 (Phase 4)**: Depends on Foundational; depends on User Story 1's marker-tap surface (T010/T011) to attach the bottom sheet to, but its DTO/service/widget work (T014–T016) can proceed in parallel with US1
- **User Story 2 (Phase 5)**: Depends on Foundational only — independently testable, does not require US1 or US3
- **User Story 4 (Phase 6)**: Depends on Foundational only for zoom controls (T025–T026); the "my location" controls (T027–T029) reuse US2's location-resolution logic (T022) but degrade gracefully if US2 isn't implemented yet (falls straight to requesting permission)
- **Polish (Phase 7)**: Depends on all desired user stories being complete

### User Story Dependencies

- **US1 (P1)**: Foundational only
- **US3 (P1)**: Foundational + attaches to US1's marker tap handler (T010/T011)
- **US2 (P2)**: Foundational only
- **US4 (P2)**: Foundational; "my location" controls soft-depend on US2's location logic

### Within Each User Story

- DTOs before service functions before widgets before screen wiring
- Platform-specific wiring (`.ios.dart` / `.android.dart`) can proceed in parallel once shared DTOs/services/widgets exist
- Story complete before moving to next priority (recommended order: US1 → US3 → US2 → US4)

### Parallel Opportunities

- T002 and T003 (platform permission config) in parallel
- T005 and T006 (iOS/Android foundational screens) in parallel
- T007 and T009 (DTO and marker widget) in parallel; T010 and T011 (platform marker wiring) in parallel once both are done
- T014 in parallel with any remaining US1 work
- T017 and T018 (platform bottom-sheet wiring) in parallel
- T025–T028 (platform zoom/my-location controls) in parallel
- T032 and T033 (platform quickstart runs) in parallel

---

## Parallel Example: User Story 1

```bash
# Launch DTO and marker widget together:
Task: "Create CityMapPointDto in lib/api/routs/Dto/City/CityMapPointDto.dart"
Task: "Create CityMapMarker widget in lib/components/map/CityMapMarker.dart"

# Once both are done, wire each platform in parallel:
Task: "Render markers in lib/pages/Nav/Map/CityUsersMapScreen.ios.dart"
Task: "Render markers in lib/pages/Nav/Map/CityUsersMapScreen.android.dart"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 3)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: User Story 1 (markers)
4. Complete Phase 4: User Story 3 (bottom sheet + profile navigation)
5. **STOP and VALIDATE**: Run `quickstart.md` scenarios 3–11 on both platforms
6. Deploy/demo if ready — this is the core value proposition per `spec.md`

### Incremental Delivery

1. Setup + Foundational → empty map screen live on both platforms
2. Add US1 → markers render → validate independently
3. Add US3 → member list + profile navigation → validate independently → MVP complete
4. Add US2 → personalized initial camera → validate independently
5. Add US4 → zoom/my-location controls → validate independently
6. Polish → cross-platform quickstart pass

### Parallel Team Strategy

With multiple developers, after Foundational is done:

- Developer A: US1 (markers) → then US4's zoom controls
- Developer B: US3 (bottom sheet), starting DTO/service/widget work immediately, wiring to markers once US1's tap surface lands
- Developer C: US2 (geolocation), independent of A/B

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- No test tasks are included — not requested in `spec.md`; validation is manual via `quickstart.md` (T032–T033)
- Recommended completion order: US1 → US3 (MVP) → US2 → US4 → Polish
- Avoid: touching `lib/api/routs/cities/CityServices.dart` in T008 and T015 concurrently (same file, sequential dependency noted above)
