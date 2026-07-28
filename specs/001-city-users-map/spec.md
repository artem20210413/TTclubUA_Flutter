---
# Feature Specification: City Users Map Screen

**Feature Branch**: `[001-city-users-map]`

**Created**: 2026-07-26

**Status**: Draft

**Input**: User description: "Flutter City Users Map Screen — a map screen for the mobile app that shows the cities where club/service members are located, so people can visually gauge the geographic spread of members and quickly view the list of people in a given city."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See member locations on a map (Priority: P1)

A member opens the map screen and immediately sees a map with markers for every city that has at least one member, so they can visually understand where the community is concentrated.

**Why this priority**: This is the core value of the feature — without the map and its markers rendering correctly, there is no feature.

**Independent Test**: Open the map screen with a mocked city list response; verify markers appear at the correct city coordinates and reflect the right visual style based on member count.

**Acceptance Scenarios**:

1. **Given** the city map data has loaded, **When** a city has exactly one member with a profile picture, **Then** the marker shows that member's circular avatar.
2. **Given** a city marker's avatar image fails to load (network error, 403, 404), **When** the marker renders, **Then** a default styled circle marker showing "1" is shown instead.
3. **Given** a city has more than one member, or a single member without a profile picture, **When** the marker renders, **Then** it shows a branded badge/circle displaying the member count.
4. **Given** the map data request fails, **When** the screen loads, **Then** a non-blocking retry notification is shown and the user can retry without losing their place on the map.

---

### User Story 2 - Center the map on my location (Priority: P2)

A member opens the map screen and the map camera automatically centers on their current location (if they grant permission), so they can immediately see members near them.

**Why this priority**: Improves relevance of the initial view but the screen is still usable and valuable without it (falls back to a sensible default).

**Independent Test**: Open the screen with location permission granted and verify the camera centers on the device's current coordinates at the default zoom; deny permission and verify the camera instead centers on the default city (Kyiv) at the same zoom.

**Acceptance Scenarios**:

1. **Given** the user grants location permission, **When** the map screen opens, **Then** the camera focuses on the user's current coordinates at zoom level 6.0.
2. **Given** the user denies location permission or location retrieval fails, **When** the map screen opens, **Then** the camera focuses on the default center (Kyiv, 50.4501, 30.5234) at zoom level 6.0.

---

### User Story 3 - View the list of members in a city (Priority: P1)

A member taps a city marker and sees a bottom sheet listing the members located in that city, with enough detail to identify them, so they can find people to connect with in a specific location and open their full profile.

**Why this priority**: This is the second half of the core value proposition — seeing markers is only useful if the member list behind them is accessible and leads somewhere (a profile).

**Independent Test**: Tap a marker with a mocked members-by-city response; verify the bottom sheet opens with the city name, total member count, and a scrollable list of member rows (avatar, name, and minor secondary info); verify scrolling further loads additional pages; verify tapping a row navigates to that member's profile screen.

**Acceptance Scenarios**:

1. **Given** a city marker with one or more members, **When** the user taps it, **Then** a bottom sheet opens showing the city name and total member count as a header.
2. **Given** the bottom sheet is open, **When** the member list loads, **Then** each row shows the member's avatar, name, and minor secondary details (e.g. roles), kept compact for a list row rather than a full detail view.
3. **Given** a member's avatar is the default placeholder image or fails to load, **When** their row renders, **Then** a fallback avatar (initials or branded icon) is shown instead.
4. **Given** a city has more members than fit in one page, **When** the user scrolls to the bottom of the list, **Then** the next page of members loads automatically and appends to the list.
5. **Given** the member list request fails, **When** the bottom sheet is open, **Then** a non-blocking retry notification is shown and the user can retry loading that page.
6. **Given** the member list is showing, **When** the user taps a specific member's row, **Then** the app navigates to that member's existing profile screen, which is responsible for showing full contact details (Telegram, Instagram, roles, last updated, etc.).

---

### User Story 4 - Control the map view with on-screen controls (Priority: P2)

A member uses on-screen zoom in/out buttons and a "my location" button to adjust the map view and quickly recenter on their own position, without relying on pinch gestures.

**Why this priority**: Improves usability and accessibility of map navigation but the map remains functional via standard gestures without these controls.

**Independent Test**: Open the map screen; tap zoom-in and verify the camera zoom level increases by one native map step; tap zoom-out and verify it decreases; tap the "my location" button and verify the camera recenters on the device's current location.

**Acceptance Scenarios**:

1. **Given** the map screen is open, **When** the user taps the zoom-in ("+") control, **Then** the map camera zooms in one step using the native map engine's zoom behavior.
2. **Given** the map screen is open, **When** the user taps the zoom-out ("−") control, **Then** the map camera zooms out one step using the native map engine's zoom behavior.
3. **Given** the map screen is open and location permission is available, **When** the user taps the "my location" control, **Then** the map camera recenters and animates to the user's current location.
4. **Given** the user taps the "my location" control but location permission is not granted or location is unavailable, **When** the tap occurs, **Then** the system requests permission (if not yet determined) or shows a non-blocking notice that location is unavailable, without crashing or freezing the map.

---

### Edge Cases

- What happens when the device has no network connectivity at all when the screen opens? The map should still render (using any cached base map data available) and a retry notification should prompt the user once city data fails to load.
- What happens when a city has zero members (data anomaly)? No marker should be rendered for that city.
- What happens when the user taps a marker while a previous bottom sheet's data is still loading? The prior request should be cancelled/ignored and the new city's data loaded.
- What happens when avatar images are slow to load? A placeholder should show while loading, replaced by the image (or fallback) once resolved, without blocking the marker/list from rendering.
- What happens when the user revokes location permission while the app is backgrounded and returns to the map screen? Permission state should be re-checked each time the screen becomes active initial load only re-checks on screen entry, not continuously.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST display a map screen showing one marker per city that has at least one member.
- **FR-002**: The system MUST request the device's location permission when the map screen opens.
- **FR-003**: When location permission is granted, the system MUST center the map camera on the user's current coordinates at zoom level 6.0.
- **FR-004**: When location permission is denied or location cannot be determined, the system MUST center the map camera on the default location (Kyiv: 50.4501, 30.5234) at zoom level 6.0.
- **FR-005**: The system MUST load city marker data (city coordinates, member count, and representative avatar) from the city map data source when the screen opens.
- **FR-006**: When a city has exactly one member and that member has a profile picture, the marker MUST display that member's avatar in a circular marker.
- **FR-007**: When a city's marker avatar image cannot be loaded, the system MUST display a default styled circle marker with the number "1".
- **FR-008**: When a city has more than one member, or its single member has no profile picture, the marker MUST display a branded badge/circle showing the total member count for that city.
- **FR-009**: The system MUST cache remote marker and member avatar images so they are not re-downloaded on subsequent views within the same session.
- **FR-010**: Tapping a city marker with one or more members MUST open a bottom sheet showing that city's member list.
- **FR-011**: The system MUST load a city's member list from the members-by-city data source, using pagination, when its bottom sheet opens.
- **FR-012**: The bottom sheet MUST display a header with the city name and the total member count.
- **FR-013**: Each member row in the list MUST display the member's avatar, name, and minor secondary information (e.g. roles), sized appropriately for a compact list row.
- **FR-014**: When a member's avatar is the default placeholder image or fails to load, the system MUST show a fallback avatar (initials or branded icon) in its place.
- **FR-015**: The member list MUST support infinite scroll, automatically loading and appending the next page as the user scrolls near the end of the current list.
- **FR-016**: If loading the city map data fails, the system MUST show a non-blocking notification with a retry action, and MUST NOT prevent the rest of the screen (map) from being usable.
- **FR-017**: If loading a page of a city's member list fails, the system MUST show a non-blocking notification with a retry action for that page.
- **FR-018**: Tapping a member's row in the list MUST navigate the user to that member's existing profile screen (full contact details, e.g. Telegram, Instagram, roles, last updated, are shown there, not in the row).
- **FR-019**: The map screen MUST provide on-screen zoom-in and zoom-out controls using the native map engine's built-in zoom behavior.
- **FR-020**: The map screen MUST provide a "my location" control that recenters the map camera on the user's current location when tapped.
- **FR-021**: If the "my location" control is tapped without an available location (permission not granted or location unavailable), the system MUST request permission or show a non-blocking notice, without disrupting the rest of the map.

### Key Entities

- **City Map Point**: Represents a city with at least one member; attributes include city identifier, city name, coordinates (latitude/longitude), member count, and an optional representative avatar image.
- **City Member**: Represents a single member within a city's member list; attributes include profile image, display name, roles, Telegram handle, Instagram handle, and last-updated date/time.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A member can identify how many people are in a given city within 2 taps of opening the map screen (open screen → tap marker).
- **SC-006**: A member can reach any listed member's full profile in exactly 2 taps from the map screen (tap marker → tap member row).
- **SC-002**: 95% of city marker avatar images that are available load and display correctly without falling back to the default placeholder, under normal network conditions.
- **SC-003**: The member list for a city remains scrollable and continues loading additional members without the user needing to manually retry, for cities with any number of members.
- **SC-004**: When the map or member data fails to load, the user can recover (see data displayed) by tapping "Retry" without restarting the screen, in under 2 actions.
- **SC-005**: Returning to a previously viewed city's member list or map markers within the same session does not require re-downloading previously loaded avatar images.

## Assumptions

- The city map data endpoint returns, per city, at minimum: city id, name, coordinates, member count, and an optional avatar URL representative of that city's members.
- The per-city member list endpoint accepts a city id and pagination parameters, and returns member profile image, name, roles, Telegram handle, Instagram handle, and last-updated timestamp.
- "Roles" refers to an existing member attribute already used elsewhere in the app (e.g., club role designations) and does not need new business rules defined here.
- Members without Telegram or Instagram handles simply omit those fields; this is not an error state, and these details are shown on the member's profile screen rather than in the compact list row.
- Full member details (contacts, roles, last updated) are shown by navigating to the existing member profile screen; the bottom sheet list row itself only needs to carry enough information to identify the member (avatar, name, minor secondary info) and enough data to navigate to their profile.
- Map zoom in/out and "my location" controls use the native map engine's own camera/zoom animation behavior rather than a custom-built one.
- The default placeholder avatar (referred to as `profile_picture.webp` in current data) is a known, recognizable "no photo set" value distinct from a genuine load failure, and both cases resolve to the same fallback treatment.
- Location permission is requested once per screen visit; the feature does not need to continuously track the user's location while the map is open.
- This feature is mobile-only (iOS and Android); no tablet- or web-specific layout requirements are in scope.
- Existing app-wide session/authentication is assumed already in place for accessing these endpoints; this spec does not define new auth requirements.
