import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../api/routs/Dto/City/CityMapPointDto.dart';
import '../../../api/routs/cities/CityServices.dart';
import '../../../components/TTLoading.dart';
import '../../../components/map/CityMapMarker.dart';
import '../../../components/map/CityMembersBottomSheet.dart';
import '../../../utils/RetrySnackBar.dart';
import 'CityUsersMapScreen.dart';
import 'MapControlButton.dart';

class CityUsersMapScreenAndroid extends StatefulWidget {
  final CityMapCameraTarget initialCameraTarget;

  const CityUsersMapScreenAndroid({super.key, required this.initialCameraTarget});

  @override
  State<CityUsersMapScreenAndroid> createState() => _CityUsersMapScreenAndroidState();
}

class _CityUsersMapScreenAndroidState extends State<CityUsersMapScreenAndroid> {
  final MapController _controller = MapController();
  List<CityMapPointDto> _cityPoints = [];
  bool _isLoading = true;
  bool _bottomSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _loadCityPoints();
  }

  Future<void> _loadCityPoints() async {
    setState(() => _isLoading = true);

    final result = await CityServices.fetchCityMapPoints(context);

    if (!mounted) return;

    if (result == null) {
      setState(() => _isLoading = false);
      showRetrySnackBar(
        context,
        'Не вдалося завантажити карту учасників',
        onRetry: _loadCityPoints,
      );
      return;
    }

    setState(() {
      // Skip cities with no members defensively (Edge Cases).
      _cityPoints = result.where((point) => point.usersCount >= 1).toList();
      _isLoading = false;
    });
  }

  void _onMarkerTap(CityMapPointDto point) {
    if (_bottomSheetOpen) {
      Navigator.of(context).pop();
    }
    _bottomSheetOpen = true;
    showCityMembersBottomSheet(context, point).whenComplete(() {
      _bottomSheetOpen = false;
    });
  }

  void _onZoomIn() {
    final camera = _controller.camera;
    _controller.move(camera.center, camera.zoom + 1);
  }

  void _onZoomOut() {
    final camera = _controller.camera;
    _controller.move(camera.center, camera.zoom - 1);
  }

  Future<void> _onMyLocation() async {
    final target = await CityLocationResolver.resolveCurrentLocation();
    if (target == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Геолокація недоступна'),
      ));
      return;
    }
    _controller.move(LatLng(target.latitude, target.longitude), target.zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: LatLng(
              widget.initialCameraTarget.latitude,
              widget.initialCameraTarget.longitude,
            ),
            initialZoom: widget.initialCameraTarget.zoom,
          ),
          children: [
            TileLayer(
              // CARTO Voyager — free, no API key, light style close to Apple Maps.
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'ua.com.ttclub.app',
              retinaMode: RetinaMode.isHighDensity(context),
            ),
            RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              attributions: [
                TextSourceAttribution('© OpenStreetMap contributors'),
                TextSourceAttribution('© CARTO'),
              ],
            ),
            MarkerLayer(
              markers: _cityPoints
                  .map((point) => Marker(
                        point: LatLng(point.latitude, point.longitude),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => _onMarkerTap(point),
                          child: CityMapMarker(point: point),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
        if (_isLoading)
          const Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(child: TTLoading()),
          ),
        Positioned(
          right: 16,
          bottom: 24,
          child: Column(
            children: [
              MapControlButton(icon: Icons.add, onTap: _onZoomIn),
              const SizedBox(height: 8),
              MapControlButton(icon: Icons.remove, onTap: _onZoomOut),
              const SizedBox(height: 8),
              MapControlButton(icon: Icons.my_location, onTap: _onMyLocation),
            ],
          ),
        ),
      ],
    );
  }
}
