import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/Search/ImageUrlDto.dart';
import 'package:tt_club_ua/components/TTLoading.dart';

/// Fullscreen gallery that browses an entire image collection.
///
/// Opens on a chosen image, supports horizontal swipe to page through all
/// images, pinch / double-tap zoom with bounded pan, and closes on a vertical
/// swipe (at normal zoom), a tap outside the image, or the platform back
/// action. Returns the index of the last image shown so the caller (carousel)
/// can sync its own position.
class FullImageGallery extends StatefulWidget {
  final List<ImageUrlDto> images;
  final int initialIndex;

  const FullImageGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  /// Opens the gallery and resolves with the last-viewed index.
  static Future<int> show(
    BuildContext context, {
    required List<ImageUrlDto> images,
    required int initialIndex,
  }) async {
    if (images.isEmpty) return initialIndex;
    final clamped = initialIndex.clamp(0, images.length - 1);

    final result = await Navigator.of(context).push<int>(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => FullImageGallery(
          images: images,
          initialIndex: clamped,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );

    return result ?? clamped;
  }

  @override
  State<FullImageGallery> createState() => _FullImageGalleryState();
}

class _FullImageGalleryState extends State<FullImageGallery> {
  late final PageController _pageController;
  late int _current;

  // One transform controller per page so each image keeps its own zoom state.
  final Map<int, TransformationController> _controllers = {};

  // Per-page key on the image box, used to hit-test taps against the visible
  // image rect (tap outside the image closes the viewer).
  final Map<int, GlobalKey> _imageKeys = {};

  // Drag-to-close state (active only at normal zoom).
  double _dragDy = 0;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TransformationController _controllerFor(int index) {
    return _controllers.putIfAbsent(index, () => TransformationController());
  }

  GlobalKey _imageKeyFor(int index) {
    return _imageKeys.putIfAbsent(index, () => GlobalKey());
  }

  bool get _isZoomed {
    final controller = _controllers[_current];
    if (controller == null) return false;
    return controller.value.getMaxScaleOnAxis() > 1.05;
  }

  void _close() {
    if (_closing) return;
    _closing = true;
    Navigator.of(context).pop(_current);
  }

  // Close only when the tap lands outside the visible image rect (FR-008);
  // a tap on the image itself is inert (FR-011a). Ignored while zoomed.
  void _handleTapUp(TapUpDetails details) {
    if (_isZoomed) return;
    final box = _imageKeys[_current]?.currentContext?.findRenderObject()
        as RenderBox?;
    if (box == null) {
      _close();
      return;
    }
    final rect = box.localToGlobal(Offset.zero) & box.size;
    if (!rect.contains(details.globalPosition)) {
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMany = widget.images.length > 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Vertical drag closes the viewer, but only at normal zoom so a
          // zoomed pan is never mistaken for a dismiss gesture. A tap is routed
          // through _handleTapUp so only taps outside the image close it.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: _handleTapUp,
              onVerticalDragUpdate: (details) {
                if (_isZoomed) return;
                _dragDy += details.delta.dy;
              },
              onVerticalDragEnd: (_) {
                if (!_isZoomed && _dragDy.abs() > 90) {
                  _close();
                }
                _dragDy = 0;
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, index) => _buildPage(index),
              ),
            ),
          ),

          if (hasMany)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: _buildIndicator(widget.images.length),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    final img = widget.images[index];
    // Zoom is by pinch only (InteractiveViewer). The image carries a key so a
    // tap can be hit-tested against its visible rect in _handleTapUp.
    return InteractiveViewer(
      transformationController: _controllerFor(index),
      panEnabled: true,
      minScale: 1,
      maxScale: 4,
      onInteractionEnd: (_) => setState(() {}),
      child: Center(
        child: Hero(
          tag: img.id.toString(),
          child: CachedNetworkImage(
            key: _imageKeyFor(index),
            imageUrl: img.url,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: TTLoading(),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.white38,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Position indicator styled to match the carousel dots for consistency.
  Widget _buildIndicator(int count) {
    const int maxVisibleDots = 13;

    List<Widget> dots;
    if (count <= maxVisibleDots) {
      dots = List.generate(count, (i) => _dot(i));
    } else {
      int start = _current - (maxVisibleDots ~/ 2);
      if (start < 0) start = 0;
      if (start + maxVisibleDots > count) start = count - maxVisibleDots;
      dots = List.generate(maxVisibleDots, (i) => _dot(start + i));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dots,
    );
  }

  Widget _dot(int index) {
    final isSelected = _current == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isSelected ? 12 : 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
      ),
    );
  }
}
