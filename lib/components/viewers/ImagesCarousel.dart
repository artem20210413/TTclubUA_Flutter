import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/Storage/Search/ImageUrlDto.dart';

class ImagesCarousel extends StatefulWidget {
  final List<ImageUrlDto> images;
  final double height;
  final double borderRadius;
  final bool showDots;

  const ImagesCarousel({
    super.key,
    required this.images,
    this.height = 220,
    this.borderRadius = 24,
    this.showDots = true,
  });

  @override
  State<ImagesCarousel> createState() => _ImagesCarouselState();
}

class _ImagesCarouselState extends State<ImagesCarousel> {
  final PageController _pageController = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.images.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: TTColors.card,
        borderRadius: BorderRadius.circular(widget.borderRadius + 8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: SizedBox(
              height: widget.height,
              child: hasImages
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: widget.images.length,
                      onPageChanged: (i) {
                        setState(() => _current = i);
                      },
                      itemBuilder: (_, index) {
                        final img = widget.images[index];
                        return Image(
                          image: img.networkImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    )
                  : _buildEmptyImage(),
            ),
          ),
          const SizedBox(height: 10),
          if (widget.showDots && hasImages && widget.images.length > 1)
            _buildDots(widget.images.length),
        ],
      ),
    );
  }

  Widget _buildDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _current == index ? Colors.white : Colors.white24,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyImage() {
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white38,
        size: 40,
      ),
    );
  }
}
