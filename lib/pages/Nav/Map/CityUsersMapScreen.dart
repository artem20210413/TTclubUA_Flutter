import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../components/TTLoading.dart';
import '../../../components/layout/TTScaffold.dart';
import '../../../components/map/MapLayerSwitch.dart';
import '../../../Storage/UserStorage.dart';
import 'CityUsersMapScreen.android.dart';
import 'CityUsersMapScreen.ios.dart';
import 'MapLayer.dart';

/// Default camera center/zoom when location permission is unavailable/denied
/// (Kyiv), per FR-004.
const double kDefaultCityMapLatitude = 50.4501;
const double kDefaultCityMapLongitude = 30.5234;
const double kDefaultCityMapZoom = 9.0;

class CityMapCameraTarget {
  final double latitude;
  final double longitude;
  final double zoom;

  const CityMapCameraTarget({
    required this.latitude,
    required this.longitude,
    this.zoom = kDefaultCityMapZoom,
  });

  static const CityMapCameraTarget defaultTarget = CityMapCameraTarget(
    latitude: kDefaultCityMapLatitude,
    longitude: kDefaultCityMapLongitude,
  );
}

/// Shared geolocation resolution used both for the initial camera position
/// and for the "my location" control on both platforms (research.md §3).
class CityLocationResolver {
  /// Returns null when permission is unavailable/denied or resolution fails,
  /// so callers can fall back to the default center or show a non-blocking
  /// notice instead of crashing/freezing the map (FR-002-FR-004, FR-021).
  static Future<CityMapCameraTarget?> resolveCurrentLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled ||
          permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition().timeout(
        const Duration(seconds: 10),
      );
      return CityMapCameraTarget(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Entry point for the city users map screen (FR-001-FR-021).
/// Delegates rendering to a platform-specific implementation: native Apple
/// Maps on iOS, flutter_map/OpenStreetMap on Android — see plan.md/research.md.
class CityUsersMapScreen extends StatefulWidget {
  const CityUsersMapScreen({super.key});

  @override
  State<CityUsersMapScreen> createState() => _CityUsersMapScreenState();
}

class _CityUsersMapScreenState extends State<CityUsersMapScreen> {
  CityMapCameraTarget _initialCameraTarget = CityMapCameraTarget.defaultTarget;
  bool _resolvedLocation = false;
  MapLayer _activeLayer = MapLayer.ours;
  // The "fa-fa" layer switch is admin-only for now — everyone else always
  // sees the "our location" layer, as before this feature existed.
  bool _isAdmin = false;

  void _setActiveLayer(MapLayer layer) {
    setState(() => _activeLayer = layer);
  }

  @override
  void initState() {
    super.initState();
    _resolveInitialLocation();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await UserStorage.isAdmin();
    if (!mounted) return;
    setState(() => _isAdmin = isAdmin);
  }

  /// Resolves the initial camera target from the device's current location,
  /// falling back to Kyiv on any denial/error (FR-002-FR-004).
  Future<void> _resolveInitialLocation() async {
    final target = await CityLocationResolver.resolveCurrentLocation();
    if (!mounted) return;
    setState(() {
      _initialCameraTarget = target ?? CityMapCameraTarget.defaultTarget;
      _resolvedLocation = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
        title: 'Карта клубу',
        body: !_resolvedLocation
            ? const Center(child: TTLoading())
            : Padding(
                padding: const EdgeInsetsGeometry.only(top: 8),
                child: Stack(
                  children: [
                    Platform.isIOS
                        ? CityUsersMapScreenIOS(
                            initialCameraTarget: _initialCameraTarget,
                            activeLayer: _activeLayer,
                          )
                        : CityUsersMapScreenAndroid(
                            initialCameraTarget: _initialCameraTarget,
                            activeLayer: _activeLayer,
                          ),
                    if (_isAdmin)
                      Positioned(
                        top: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: MapLayerSwitch(
                            activeLayer: _activeLayer,
                            onChanged: _setActiveLayer,
                          ),
                        ),
                      ),
                  ],
                ),
              ));
  }
}
