# API Contract: City Map & City Members Endpoints

These are pre-existing backend endpoints this feature consumes (not created by this feature). Documented here as the client-side contract the Flutter DTOs (`CityMapPointDto`, `CityMemberDto`) must satisfy; exact field names/pagination shape should be confirmed against the live backend during implementation and this file updated to match reality.

## `GET api/cities/map`

Returns every city that has at least one member, for rendering map markers.

**Request**: no query params expected (full list); standard auth header (`HEADERS(token)` per project convention).

**Response** (200): JSON array of city map points.

```json
[
  {
    "id": 12,
    "name": "Kyiv",
    "latitude": 50.4501,
    "longitude": 30.5234,
    "users_count": 3,
    "avatar": "https://.../avatar.jpg"
  }
]
```

**Client mapping** → `CityMapPointDto` (see `data-model.md`): `avatar` → `avatarUrl` (nullable), `users_count` → `usersCount`.

**Error handling**: any non-200 or network failure → screen shows non-blocking retry SnackBar (FR-016); map remains interactive.

## `GET api/cities/{id}/users`

Returns a paginated list of members located in the given city, for the bottom sheet.

**Request**: path param `id` (city id, `int`), query param(s) for pagination — page number convention TBD against live backend (project's existing `SearchUser.dart` pattern uses a `page` query param and infers `hasMore` from `results.length >= pageSize`; apply the same approach here unless the backend returns an explicit `has_more`/`next_page` field).

**Response** (200): JSON array (or paginated wrapper) of city members.

```json
[
  {
    "id": 42,
    "name": "Oleh Ivanenko",
    "profile_image": "https://.../profile.jpg",
    "roles": ["driver"],
    "telegram_nickname": "oleh_tt",
    "instagram_nickname": null,
    "updated_at": "2026-06-01T10:00:00Z"
  }
]
```

**Client mapping** → `CityMemberDto` (see `data-model.md`).

**Error handling**: any non-200 or network failure while loading a page → non-blocking retry SnackBar scoped to that page load (FR-017); does not close the bottom sheet or discard already-loaded rows.
