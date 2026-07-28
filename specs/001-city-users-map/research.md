# Phase 0 Research: City Users Map Screen

## 1. Map engine per platform

**Decision**: iOS uses `apple_maps_flutter` (wraps native `MKMapView`/Apple Maps). Android uses `flutter_map` with OpenStreetMap raster tiles (`latlong2` for coordinates).

**Rationale**: The spec explicitly requires native Apple Maps on iOS. For Android, `google_maps_flutter` is the natural Apple Maps analogue but requires a Google Cloud project, an API key, and a billing account (its "free tier" still needs billing enabled) — user confirmed this is unwanted friction. `flutter_map` + OSM tiles has no API key, no billing, no usage cap for reasonable app traffic, and is a well-maintained, widely used Flutter package.

**Alternatives considered**:
- `google_maps_flutter` on Android — rejected: requires billing-enabled API key, contradicts "бесплатное" requirement.
- A single cross-platform engine (`flutter_map` on both iOS and Android) — rejected: spec explicitly requires *native* Apple Maps on iOS, not an OSM-tile rendering.
- `mapbox_gl` — rejected: also requires an API token and has usage-based billing beyond a free quota.

## 2. Marker rendering strategy

**Decision**: A single shared Flutter widget, `CityMapMarker`, renders the avatar-circle or count-badge visual (built with `TTNeumorphicBox`/`CircleAvatar`). Each platform screen implementation is responsible for turning that widget into a marker/annotation using its own engine's API:
- `apple_maps_flutter`: `Annotation` positions support a custom icon; since `apple_maps_flutter` markers are image-based (not arbitrary widgets), the shared `CityMapMarker` widget is rasterized to an image (via `RepaintBoundary` + `toImage`) once per unique city payload (avatar+count combination) and cached, then supplied as the annotation icon.
- `flutter_map`: markers are native Flutter widgets via the `MarkerLayer`, so `CityMapMarker` is used directly as the marker child with no rasterization needed.

**Rationale**: Keeps visual logic (styling, TTNeumorphicBox glass/merge effect, avatar fallback, count formatting) in exactly one place, satisfying "должны выглядеть должны одинаково" without duplicating design logic across two platform files. Only the "how do I get a widget onto this specific map engine" glue code differs.

**Alternatives considered**: Fully separate marker widgets per platform — rejected, doubles the surface area for a purely visual concern and risks visual drift between iOS/Android over time.

## 3. Location permission & positioning

**Decision**: Use `geolocator` package: call `Geolocator.checkPermission()`/`requestPermission()` once per screen entry (in `initState`), then `Geolocator.getCurrentPosition()`. On success, center camera at that position, zoom 6.0. On any denial/error (`PermissionDeniedException`, `LocationServiceDisabledException`, timeout, etc.), fall back to Kyiv (50.4501, 30.5234), zoom 6.0 — treat all failure modes uniformly per the spec's edge case handling, no special-casing per error type.

**Rationale**: `geolocator` is the de facto standard Flutter geolocation package (referenced directly in the feature description) and already handles both iOS/Android permission plumbing (still requires adding `NSLocationWhenInUseUsageDescription` to `Info.plist` and the `ACCESS_FINE_LOCATION` permission to `AndroidManifest.xml`).

**Alternatives considered**: Platform channels written by hand — rejected, reinventing a well-solved problem.

## 4. Image caching for avatars

**Decision**: Use `cached_network_image` for both marker avatars and bottom-sheet list row avatars, backed by its default disk+memory cache manager.

**Rationale**: Directly satisfies FR-009 (no re-download within a session) and SC-005, with zero custom caching code. No existing caching solution exists in the codebase (confirmed via research) so this is a net-new, low-risk addition; it degrades gracefully to `errorBuilder` fallback (used to trigger the "default circle with 1" / initials fallback in FR-007/FR-014).

**Alternatives considered**: Manual `Image.network` + a hand-rolled `Map<String, Uint8List>` cache — rejected as unnecessary reinvention.

## 5. API access pattern

**Decision**: Add two new functions to the existing `lib/api/routs/cities/CityServices.dart` file (extending the current per-domain file rather than introducing a new "ApiClient" abstraction), using `package:http` (the dominant pattern in the codebase, `dio` is only used in 2 files and is not the convention to extend):
- `fetchCityMapPoints()` → `GET api/cities/map`
- `fetchCityMembers(int cityId, {int page})` → `GET api/cities/{id}/users`

Both follow the existing `SEARCH_USER`-style plain-function pattern (`lib/api/routs/user.dart`), reading base URL constants from `lib/api/routs/root.dart` and auth headers via the existing `HEADERS(token)` helper.

**Rationale**: Matches project convention exactly (verified: no central API client exists; `http` dominates; DTOs are hand-written, not generated).

**Alternatives considered**: Introducing Dio + interceptors as a new standard — rejected, out of scope for this feature and inconsistent with 95% of existing call sites.

## 6. DTO shape

**Decision**: Two new manual DTOs mirroring the existing `CityDto`/`UserSmallDto` style (`fromJson` factory with `??` defaults and `(json['x'] as num?)?.toDouble()` for doubles; keep raw JSON `Map` around only if a screen needs pass-through fields, matching `UserSmallDto`'s pattern):
- `CityMapPointDto`: `id`, `name`, `latitude`, `longitude`, `usersCount`, `avatarUrl` (nullable)
- `CityMemberDto`: `id`, `name`, `profileImage`, `roles` (List<String> or similar existing roles shape — confirm against `UserSmallDto`/`UserUpdateDto` roles field during implementation), `telegramNickname` (nullable), `instagramNickname` (nullable), `updatedAt`

**Rationale**: Consistency with every other DTO in `lib/api/routs/Dto/`; no `json_serializable`/build_runner is used anywhere in the project, so introducing one here would be an unjustified new dependency.

## 7. Pagination pattern for the bottom sheet member list

**Decision**: Reuse the `SearchUser.dart` pattern: `_page` int starting at 1, `_hasMore` bool, `ScrollController` listener firing near `maxScrollExtent`, `_hasMore = data.length >= pageSize` heuristic (page size to match whatever `GET api/cities/{id}/users` defaults to, confirmed during implementation against the live endpoint/backend contract).

**Rationale**: Directly matches an existing, working infinite-scroll implementation already in the app; no new pagination abstraction needed.

## 8. Bottom sheet UI pattern

**Decision**: Reuse the `showModalBottomSheet<T>(isScrollControlled: true, backgroundColor: TTColors.background, ...)` pattern from `CitiesPicker.dart`, with a `StatefulBuilder`/separate `StatefulWidget` (`CityMembersBottomSheet`) owning its own pagination state, header (city name + count), and list of rows built from `TTNeumorphicBox`.

**Rationale**: Matches the one existing bottom-sheet reference in the codebase; keeps visual language (neumorphic chrome) consistent with the rest of the app.

## 9. Navigating to member profile

**Decision**: Each bottom-sheet row navigates via `Navigator.push(context, MaterialPageRoute(builder: (_) => Profile(id: member.id)))`, matching `Profile`'s actual constructor (`Profile({super.key, this.id})`, nullable `int? id`) and the app's existing `Navigator.push` convention (no named routes/go_router in this project).

**Rationale**: Directly verified against `Profile.dart`'s constructor; no new navigation infrastructure needed.
