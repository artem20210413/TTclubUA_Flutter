import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/Storage/Search/ImageUrlDto.dart';

import '../card/CarImageBlock.dart';

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
      child: Stack(
        clipBehavior: Clip.none,
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
                        return CarImageBlock(
                          uniqueKey: img.id.toString(),
                          imageUrl: img.url,
                        );
                      },
                    )
                  : _buildEmptyImage(),
            ),
          ),
          // const SizedBox(height: 10),
          if (widget.showDots && hasImages && widget.images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: _buildDots(widget.images.length),
            )
        ],
      ),
    );
  }

  // Widget _buildDots(int count) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: List.generate(
  //       count,
  //       (index) => Container(
  //         width: 8,
  //         height: 8,
  //         margin: const EdgeInsets.symmetric(horizontal: 4),
  //         decoration: BoxDecoration(
  //           shape: BoxShape.circle,
  //           color: _current == index ? Colors.white : Colors.black54,
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildDots(int count) {
    // Налаштування: скільки всього крапок ми хочемо бачити в рядку
    const int maxVisibleDots = 13;

    // Якщо крапок мало — малюємо як зазвичай
    if (count <= maxVisibleDots) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) => _dot(index)),
      );
    }

    // Розраховуємо вікно видимості крапок (щоб поточна була по центру)
    int start = _current - (maxVisibleDots ~/ 2);
    if (start < 0) start = 0;
    if (start + maxVisibleDots > count) start = count - maxVisibleDots;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxVisibleDots, (i) {
        final actualIndex = start + i;
        return _dot(actualIndex);
      }),
    );
  }

// Винесемо саму крапку в окремий метод для чистоти
  Widget _dot(int index) {
    final isSelected = _current == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isSelected ? 12 : 6,
      // Активна крапка трохи ширша
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
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
