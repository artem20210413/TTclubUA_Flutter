# Phase 1 Data Model: City Users Map Screen

Two new DTOs, following the project's existing manual `fromJson`/`toJson` convention (see `lib/api/routs/Dto/City/CityDto.dart`, `lib/api/routs/Dto/User/UserSmallDto.dart`). No local persistence — both are transient, in-memory response models.

## CityMapPointDto

Represents one marker on the map (`GET api/cities/map` list item). Maps to the spec's **City Map Point** entity.

| Field | Type | Nullable | Notes |
|---|---|---|---|
| `id` | `int` | no | City identifier; used to fetch the member list on tap |
| `name` | `String` | no | City display name, shown as the bottom sheet header |
| `latitude` | `double` | no | Parsed via `(json['latitude'] as num?)?.toDouble() ?? 0` |
| `longitude` | `double` | no | Parsed via `(json['longitude'] as num?)?.toDouble() ?? 0` |
| `usersCount` | `int` | no | Drives single-avatar vs. count-badge marker rendering (FR-006–FR-008) |
| `avatarUrl` | `String?` | yes | Representative avatar; `null` forces count-badge rendering per FR-008 even when `usersCount == 1` |

**Validation / derived rules**:
- A marker is only rendered if `usersCount >= 1` (cities with 0 members are not present in the response, or are filtered client-side defensively per Edge Cases).
- `showsAvatar = usersCount == 1 && avatarUrl != null` (FR-006); otherwise the count badge is shown (FR-008).

## CityMemberDto

Represents one row in a city's paginated member list (`GET api/cities/{id}/users` list item). Maps to the spec's **City Member** entity.

| Field | Type | Nullable | Notes |
|---|---|---|---|
| `id` | `int` | no | Used to navigate to `Profile(id: ...)` |
| `name` | `String` | no | Display name |
| `profileImage` | `String?` | yes | If `null` or equal to the known default placeholder filename (`profile_picture.webp`) or the image fails to load, the fallback avatar (initials/branded icon) is shown (FR-014) |
| `roles` | `List<String>` | no (defaults to `[]`) | Shown as compact secondary info in the list row (FR-013); full display deferred to `Profile` screen |
| `telegramNickname` | `String?` | yes | Omitted from the row if absent |
| `instagramNickname` | `String?` | yes | Omitted from the row if absent |
| `updatedAt` | `DateTime?` | yes | Parsed from ISO 8601 string if present; used for "last updated" display |

**Validation / derived rules**:
- `hasDefaultAvatar = profileImage == null || profileImage!.endsWith('profile_picture.webp')` → triggers fallback avatar rendering.

## Paginated response wrapper

`GET api/cities/{id}/users` is expected to return a paginated list (standard REST pagination — page number/size, or a `has_more`/`next_page` indicator.  Exact shape confirmed against the live backend contract during implementation; the client-side pagination state (`_page`, `_hasMore`) does not require the wrapper to be typed as its own DTO — `CityMemberDto.fromJson` is applied per-item to whatever list field the response contains, matching the existing `SearchUser.dart` pattern of treating the wrapper loosely.

## Relationships

- `CityMapPointDto.id` is the key used to request `CityMemberDto` pages for that city — no client-side join is needed; the bottom sheet always fetches fresh member data for the tapped city id rather than reusing map-point data.
- No relationship needs to be modeled between `CityMemberDto` and the app's existing full `User`/`UserSmallDto` models beyond sharing the same `id`, which is passed straight through to `Profile(id: ...)`.
