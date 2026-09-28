import 'dart:async';
import 'dart:ui' as ui;

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple_maps;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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

class CityUsersMapScreenIOS extends StatefulWidget {
  final CityMapCameraTarget initialCameraTarget;
  final MapLayer activeLayer;

  const CityUsersMapScreenIOS({
    super.key,
    required this.initialCameraTarget,
    required this.activeLayer,
  });

  @override
  State<CityUsersMapScreenIOS> createState() => _CityUsersMapScreenIOSState();
}

class _CityUsersMapScreenIOSState extends State<CityUsersMapScreenIOS> {
  apple_maps.AppleMapController? _controller;
  final Set<apple_maps.Annotation> _cityAnnotations = {};
  final Set<apple_maps.Annotation> _faFaAnnotations = {};
  List<MentionLocationPointDto> _faFaPoints = [];
  bool _faFaLoaded = false;
  bool _isLoading = true;
  bool _bottomSheetOpen = false;

  // Coalesces overlapping recompute calls fired in quick succession (e.g.
  // during a continuous pinch-zoom) so screen-coordinate lookups never pile
  // up concurrently — see _recomputeFaFaOverlay.
  bool _recomputeInFlight = false;
  bool _recomputePending = false;

  // Guards against a stale response from a previous, superseded fetch
  // winning a race against a newer one (FR-014).
  int _cityRequestGeneration = 0;
  int _faFaRequestGeneration = 0;

  // Each layer's alpha is a plain target value (Annotation.alpha), swapped
  // in two simple, sequential setState steps: the outgoing set drops to 0
  // immediately, and the incoming set only rises to 1 after a short delay
  // — so the two annotation sets are never both partially visible at once,
  // and (unlike a shared AnimationController) the final value is always
  // exactly 0 or 1, never left stuck at a mid-transition value (FR-007/FR-008).
  static const _fadeStep = Duration(milliseconds: 180);
  double _cityAlpha = 1;
  double _faFaAlpha = 0;
  int _switchGeneration = 0;

  void _applyLayerVisibility(MapLayer layer) {
    final generation = ++_switchGeneration;
    setState(() {
      if (layer == MapLayer.fafa) {
        _cityAlpha = 0;
      } else {
        _faFaAlpha = 0;
      }
    });
    Future.delayed(_fadeStep, () {
      if (!mounted || generation != _switchGeneration) return;
      setState(() {
        if (layer == MapLayer.fafa) {
          _faFaAlpha = 1;
        } else {
          _cityAlpha = 1;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _cityAlpha = widget.activeLayer == MapLayer.fafa ? 0 : 1;
    _faFaAlpha = widget.activeLayer == MapLayer.fafa ? 1 : 0;
    _loadCityPoints();
    if (widget.activeLayer == MapLayer.fafa) {
      _loadFaFaPoints();
    }
  }

  @override
  void didUpdateWidget(CityUsersMapScreenIOS oldWidget) {
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

    // Skip cities with no members defensively (Edge Cases).
    final points = result.where((point) => point.usersCount >= 1).toList();
    final annotations = await _buildCityAnnotations(points);

    if (!mounted || generation != _cityRequestGeneration) return;
    setState(() {
      _cityAnnotations
        ..clear()
        ..addAll(annotations);
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

    if (!mounted || generation != _faFaRequestGeneration) return;
    setState(() {
      _faFaPoints = aggregateByCoordinate(result);
      _faFaLoaded = true;
      _isLoading = false;
    });
    await _recomputeFaFaOverlay();
  }

  /// Re-clusters and re-projects the "fa-fa" points for the current camera
  /// (FR-015/FR-016) and rebuilds their annotations.
  ///
  /// Coalesces overlapping calls: if a recompute is already running when
  /// this is called again (e.g. fired repeatedly during a pinch gesture),
  /// the new request is deferred until the in-flight one finishes, rather
  /// than running many concurrent screen-coordinate lookups — this keeps
  /// cluster markers updating smoothly instead of jumping once at the end.
  Future<void> _recomputeFaFaOverlay() async {
    if (_recomputeInFlight) {
      _recomputePending = true;
      return;
    }
    _recomputeInFlight = true;
    try {
      await _doRecomputeFaFaOverlay();
    } finally {
      _recomputeInFlight = false;
      if (_recomputePending) {
        _recomputePending = false;
        unawaited(_recomputeFaFaOverlay());
      }
    }
  }

  Future<void> _doRecomputeFaFaOverlay() async {
    if (_controller == null || _faFaPoints.isEmpty) {
      if (!mounted) return;
      setState(() {
        _faFaAnnotations.clear();
      });
      return;
    }

    final screenPoints = <String, Offset>{};
    for (final point in _faFaPoints) {
      final coordinate = await _controller!.getScreenCoordinate(
        apple_maps.LatLng(point.latitude, point.longitude),
      );
      if (coordinate != null) {
        screenPoints['${point.latitude},${point.longitude}'] = coordinate;
      }
    }
    if (!mounted) return;

    final clusters = computeClusters(
      _faFaPoints,
      projectToScreen: (lat, lng) => screenPoints['$lat,$lng'],
    );

    final annotations = <apple_maps.Annotation>{};
    for (var i = 0; i < clusters.length; i++) {
      final cluster = clusters[i];
      final icon = await _rasterizeCountMarker(
        cluster.totalCount,
        isCluster: cluster.isCluster,
      );
      annotations.add(apple_maps.Annotation(
        annotationId: apple_maps.AnnotationId('fafa_$i'),
        position:
            apple_maps.LatLng(cluster.centerLatitude, cluster.centerLongitude),
        icon: icon,
        onTap: () => _onClusterTap(cluster),
      ));
    }

    if (!mounted) return;
    setState(() {
      _faFaAnnotations
        ..clear()
        ..addAll(annotations);
    });
  }

  Future<Set<apple_maps.Annotation>> _buildCityAnnotations(
      List<CityMapPointDto> points) async {
    final annotations = <apple_maps.Annotation>{};
    for (final point in points) {
      try {
        final icon = await _rasterizeMarker(point);
        annotations.add(apple_maps.Annotation(
          annotationId: apple_maps.AnnotationId('city_${point.id}'),
          position: apple_maps.LatLng(point.latitude, point.longitude),
          icon: icon,
          onTap: () => _onMarkerTap(point),
        ));
      } catch (e) {
        // Don't let one bad marker (e.g. a corrupt avatar) drop the rest.
        print('Failed to rasterize marker for city ${point.id}: $e');
      }
    }
    return annotations;
  }

  /// apple_maps_flutter annotations are image-based, so the shared
  /// [CityMapMarker] widget is rasterized to a PNG once per city (research.md §2).
  ///
  /// The rasterization below is synchronous (build → paint → snapshot in one
  /// go), so any avatar must already be downloaded *and fully decoded*
  /// before the widget tree is built — a live network image (still
  /// downloading) or `Image.memory` (still decoding, which is itself async)
  /// would not be ready in time and would always render as the fallback badge.
  Future<apple_maps.BitmapDescriptor> _rasterizeMarker(
      CityMapPointDto point) async {
    ui.Image? decodedAvatar;
    if (point.showsAvatar) {
      decodedAvatar = await _fetchDecodedAvatar(point.avatarUrl!);
    }

    return _rasterizeWidget(
      CityMapMarker(
        point: point,
        size: 44,
        decodedAvatarOverride: decodedAvatar,
      ),
      width: 44,
      height: 44,
    );
  }

  /// Same rasterization approach as [_rasterizeMarker], for the "fa-fa"
  /// numeric marker (FR-018/FR-019). Cached per (count, isCluster) so
  /// re-clustering on every camera move doesn't re-rasterize identical
  /// markers repeatedly.
  final Map<String, apple_maps.BitmapDescriptor> _faFaIconCache = {};

  Future<apple_maps.BitmapDescriptor> _rasterizeCountMarker(
    int count, {
    required bool isCluster,
  }) async {
    final key = '$count-$isCluster';
    final cached = _faFaIconCache[key];
    if (cached != null) return cached;

    // A small rectangle, not a big square — matches the compact pill so
    // the marker's on-screen footprint isn't padded out with empty space.
    final icon = await _rasterizeWidget(
      MentionLocationMarker(count: count, isCluster: isCluster),
      width: 52,
      height: 36,
    );
    _faFaIconCache[key] = icon;
    return icon;
  }

  Future<apple_maps.BitmapDescriptor> _rasterizeWidget(Widget child,
      {required double width, required double height}) async {
    final repaintBoundary = RenderRepaintBoundary();
    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    final renderView = RenderView(
      view: WidgetsBinding.instance.platformDispatcher.views.first,
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tightFor(width: width, height: height),
        devicePixelRatio: 2.0,
      ),
      child: RenderPositionedBox(child: repaintBoundary),
    );
    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return apple_maps.BitmapDescriptor.fromBytes(
        byteData!.buffer.asUint8List());
  }

  /// Downloads (or reads from the shared disk cache) the avatar and fully
  /// decodes it, returning null on any failure so the marker falls back to
  /// the count badge (FR-007).
  Future<ui.Image?> _fetchDecodedAvatar(String url) async {
    try {
      final file = await DefaultCacheManager().getSingleFile(url);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  void _onMarkerTap(CityMapPointDto point) {
    if (_bottomSheetOpen) {
      Navigator.of(context).pop();
    }
    _bottomSheetOpen = true;
    showCityMembersBottomSheet(context, point).whenComplete(() {
      _bottomSheetOpen = false;
      // MKMapView only calls didSelect when an annotation's selection state
      // actually changes, so re-tapping the same still-selected annotation
      // is silently ignored by the native map. Removing and re-adding it
      // resets its native selection state — but the remove and the add must
      // land in two separate frames, otherwise the AppleMap widget's diffing
      // sees no net change and never tells the native side anything happened.
      _reselectableFix(point);
    });
  }

  Future<void> _reselectableFix(CityMapPointDto point) async {
    final id = apple_maps.AnnotationId('city_${point.id}');
    apple_maps.Annotation? existing;
    for (final annotation in _cityAnnotations) {
      if (annotation.annotationId == id) {
        existing = annotation;
        break;
      }
    }
    if (existing == null || !mounted) return;

    setState(() => _cityAnnotations.remove(existing));
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    setState(() => _cityAnnotations.add(existing!));
  }

  Future<void> _onClusterTap(MentionLocationCluster cluster) async {
    if (cluster.isCluster) {
      final currentZoom = await _controller?.getZoomLevel() ?? 0;
      await _controller?.animateCamera(apple_maps.CameraUpdate.newLatLngZoom(
        apple_maps.LatLng(cluster.centerLatitude, cluster.centerLongitude),
        currentZoom + 2,
      ));
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

  Future<void> _onZoomIn() async {
    await _controller?.animateCamera(apple_maps.CameraUpdate.zoomIn());
  }

  Future<void> _onZoomOut() async {
    await _controller?.animateCamera(apple_maps.CameraUpdate.zoomOut());
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
    await _controller?.animateCamera(apple_maps.CameraUpdate.newLatLngZoom(
      apple_maps.LatLng(target.latitude, target.longitude),
      target.zoom,
    ));
  }

  Set<apple_maps.Annotation> _fadedAnnotations(
      Set<apple_maps.Annotation> annotations, double alpha) {
    if (alpha >= 1) return annotations;
    if (alpha <= 0) return const {};
    return annotations.map((a) => a.copyWith(alphaParam: alpha)).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final annotations = <apple_maps.Annotation>{
      ..._fadedAnnotations(_cityAnnotations, _cityAlpha),
      ..._fadedAnnotations(_faFaAnnotations, _faFaAlpha),
    };
    final isFaFa = widget.activeLayer == MapLayer.fafa;

    return Stack(
      children: [
        apple_maps.AppleMap(
          initialCameraPosition: apple_maps.CameraPosition(
            target: apple_maps.LatLng(
              widget.initialCameraTarget.latitude,
              widget.initialCameraTarget.longitude,
            ),
            zoom: widget.initialCameraTarget.zoom,
          ),
          annotations: annotations,
          onMapCreated: (controller) {
            _controller = controller;
            if (widget.activeLayer == MapLayer.fafa) {
              _recomputeFaFaOverlay();
            }
          },
          onCameraMove: (_) {
            if (widget.activeLayer == MapLayer.fafa) {
              _recomputeFaFaOverlay();
            }
          },
          onCameraIdle: () {
            if (widget.activeLayer == MapLayer.fafa) {
              _recomputeFaFaOverlay();
            }
          },
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
