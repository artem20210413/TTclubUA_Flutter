import 'dart:ui' as ui;

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple_maps;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../api/routs/Dto/City/CityMapPointDto.dart';
import '../../../api/routs/cities/CityServices.dart';
import '../../../components/TTLoading.dart';
import '../../../components/map/CityMapMarker.dart';
import '../../../components/map/CityMembersBottomSheet.dart';
import '../../../utils/RetrySnackBar.dart';
import 'CityUsersMapScreen.dart';
import 'MapControlButton.dart';

class CityUsersMapScreenIOS extends StatefulWidget {
  final CityMapCameraTarget initialCameraTarget;

  const CityUsersMapScreenIOS({super.key, required this.initialCameraTarget});

  @override
  State<CityUsersMapScreenIOS> createState() => _CityUsersMapScreenIOSState();
}

class _CityUsersMapScreenIOSState extends State<CityUsersMapScreenIOS> {
  apple_maps.AppleMapController? _controller;
  final Set<apple_maps.Annotation> _annotations = {};
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

    // Skip cities with no members defensively (Edge Cases).
    final points = result.where((point) => point.usersCount >= 1).toList();
    final annotations = await _buildAnnotations(points);

    if (!mounted) return;
    setState(() {
      _annotations
        ..clear()
        ..addAll(annotations);
      _isLoading = false;
    });
  }

  Future<Set<apple_maps.Annotation>> _buildAnnotations(
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

    final repaintBoundary = RenderRepaintBoundary();
    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    const double size = 44;
    final renderView = RenderView(
      view: WidgetsBinding.instance.platformDispatcher.views.first,
      configuration: const ViewConfiguration(
        logicalConstraints: BoxConstraints.tightFor(width: size, height: size),
        devicePixelRatio: 2.0,
      ),
      child: RenderPositionedBox(child: repaintBoundary),
    );
    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: CityMapMarker(
          point: point,
          size: size,
          decodedAvatarOverride: decodedAvatar,
        ),
      ),
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
    });
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

  @override
  Widget build(BuildContext context) {
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
          annotations: _annotations,
          onMapCreated: (controller) => _controller = controller,
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

