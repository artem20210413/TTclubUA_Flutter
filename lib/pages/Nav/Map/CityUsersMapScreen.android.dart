import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../api/routs/Dto/City/CityMapPointDto.dart';
import '../../../api/routs/Dto/MentionLocationPointDto.dart';
import '../../../api/routs/cities/CityServices.dart';
import '../../../api/routs/mention/MentionServices.dart';
import '../../../components/TTLoading.dart';
import '../../../components/map/CityMapMarker.dart';
import '../../../components/map/CityMembersBottomSheet.dart';
import '../../../components/map/MentionLocationMarker.dart';
import '../../../Helpers/mention_clustering.dart';
import '../../../utils/RetrySnackBar.dart';
import 'CityUsersMapScreen.dart';
import 'MapControlButton.dart';
import 'MapLayer.dart';

class CityUsersMapScreenAndroid extends StatefulWidget {
  final CityMapCameraTarget initialCameraTarget;
  final MapLayer activeLayer;

  const CityUsersMapScreenAndroid({
    super.key,
    required this.initialCameraTarget,
    required this.activeLayer,
  });

  @override
  State<CityUsersMapScreenAndroid> createState() => _CityUsersMapScreenAndroidState();
}

class _CityUsersMapScreenAndroidState extends State<CityUsersMapScreenAndroid> {
  final MapController _controller = MapController();
  List<CityMapPointDto> _cityPoints = [];
  List<MentionLocationPointDto> _faFaPoints = [];
  bool _faFaLoaded = false;
  bool _isLoading = true;
  bool _bottomSheetOpen = false;

  // Guards against a stale response from a previous, superseded fetch
  // winning a race against a newer one (FR-014).
  int _cityRequestGeneration = 0;
  int _faFaRequestGeneration = 0;

  List<MentionLocationCluster> _clusters = [];

  // Each layer's opacity is a plain target value driven by AnimatedOpacity
  // (a built-in implicit animation, guaranteed to converge to its target
  // even under rapid repeated changes — unlike a hand-rolled shared
  // AnimationController, which turned out fragile in practice). The
  // outgoing layer's opacity is dropped to 0 immediately; the incoming
  // layer's opacity is only raised to 1 after a short delay, so the two
  // are never simultaneously visible at once (FR-007/FR-008).
  static const _fadeStep = Duration(milliseconds: 180);
  double _oursOpacity = 1;
  double _faFaOpacity = 0;
  int _switchGeneration = 0;

  void _applyLayerVisibility(MapLayer layer) {
    final generation = ++_switchGeneration;
    setState(() {
      if (layer == MapLayer.fafa) {
        _oursOpacity = 0;
      } else {
        _faFaOpacity = 0;
      }
    });
    Future.delayed(_fadeStep, () {
      if (!mounted || generation != _switchGeneration) return;
      setState(() {
        if (layer == MapLayer.fafa) {
          _faFaOpacity = 1;
        } else {
          _oursOpacity = 1;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _oursOpacity = widget.activeLayer == MapLayer.fafa ? 0 : 1;
    _faFaOpacity = widget.activeLayer == MapLayer.fafa ? 1 : 0;
    _loadCityPoints();
    if (widget.activeLayer == MapLayer.fafa) {
      _loadFaFaPoints();
    }
  }

  @override
  void didUpdateWidget(CityUsersMapScreenAndroid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeLayer != widget.activeLayer) {
      if (widget.activeLayer == MapLayer.fafa && !_faFaLoaded) {
        _loadFaFaPoints();
      }
      _applyLayerVisibility(widget.activeLayer);
    }
  }

  Future<void> _loadCityPoints() async {
    final generation = ++_cityRequestGeneration;
    setState(() => _isLoading = true);

    final result = await CityServices.fetchCityMapPoints(context);

    if (!mounted || generation != _cityRequestGeneration) return;

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

  Future<void> _loadFaFaPoints() async {
    final generation = ++_faFaRequestGeneration;
    setState(() => _isLoading = true);

    final result = await MentionServices.fetchMentionLocations(context);

    if (!mounted || generation != _faFaRequestGeneration) return;

    if (result == null) {
      setState(() => _isLoading = false);
      showRetrySnackBar(
        context,
        'Не вдалося завантажити локації "фа-фа"',
        onRetry: _loadFaFaPoints,
      );
      return;
    }

    setState(() {
      _faFaPoints = aggregateByCoordinate(result);
      _faFaLoaded = true;
      _isLoading = false;
      _recomputeClusters();
    });
  }

  Offset _screenPoint(double latitude, double longitude) {
    final point =
        _controller.camera.latLngToScreenPoint(LatLng(latitude, longitude));
    return Offset(point.x, point.y);
  }

  /// Projects a lat/lng into screen coordinates for the current camera, so
  /// nearby points can be grouped by pixel distance (FR-015/FR-016).
  void _recomputeClusters() {
    if (_faFaPoints.isEmpty) {
      _clusters = [];
      return;
    }
    _clusters = computeClusters(
      _faFaPoints,
      projectToScreen: (lat, lng) => _screenPoint(lat, lng),
    );
  }

  /// Recomputes on every move/zoom step (not just when the gesture ends), so
  /// cluster markers don't visibly jump/flicker once the gesture finishes
  /// (Edge Case: rapid repeated pinch-zoom must stay smooth).
  void _onMapEvent(MapEvent event) {
    if (widget.activeLayer != MapLayer.fafa || _faFaPoints.isEmpty) return;
    setState(_recomputeClusters);
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

  void _onClusterTap(MentionLocationCluster cluster) {
    if (cluster.isCluster) {
      final camera = _controller.camera;
      _controller.move(
        LatLng(cluster.centerLatitude, cluster.centerLongitude),
        camera.zoom + 2,
      );
      return;
    }
    _showFaFaDetail(cluster.sourcePoints.first);
  }

  void _showFaFaDetail(MentionLocationPointDto point) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Кількість згадок: ${point.count}'),
      ),
    );
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
    final isFaFa = widget.activeLayer == MapLayer.fafa;

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
            onMapEvent: _onMapEvent,
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
            // Both marker layers stay permanently mounted so neither is ever
            // torn down (avoids markers failing to reappear); each fades via
            // its own independent AnimatedOpacity, sequenced by
            // _applyLayerVisibility so they're never both visible at once.
            IgnorePointer(
              ignoring: _oursOpacity == 0,
              child: AnimatedOpacity(
                duration: _fadeStep,
                opacity: _oursOpacity,
                child: MarkerLayer(
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
              ),
            ),
            IgnorePointer(
              ignoring: _faFaOpacity == 0,
              child: AnimatedOpacity(
                duration: _fadeStep,
                opacity: _faFaOpacity,
                child: MarkerLayer(
                  markers: _clusters
                      .map((cluster) => Marker(
                            point: LatLng(
                                cluster.centerLatitude, cluster.centerLongitude),
                            width: 52,
                            height: 36,
                            child: MentionLocationMarker(
                              count: cluster.totalCount,
                              isCluster: cluster.isCluster,
                              onTap: () => _onClusterTap(cluster),
                            ),
                          ))
                      .toList(),
                ),
              ),
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
        if (isFaFa && !_isLoading && _faFaLoaded && _faFaPoints.isEmpty)
          const Positioned(
            top: 72,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Даних поки немає',
                style: TextStyle(color: Colors.white),
              ),
            ),
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
