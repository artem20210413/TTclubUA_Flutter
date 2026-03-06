import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/Search/ImageUrlDto.dart';

class LittleImageThumbnail extends StatelessWidget {
  final List<ImageUrlDto> images;
  final double size;
  final double radius;

  const LittleImageThumbnail({
    super.key,
    required this.images,
    this.size = 60.0,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final hasImages = images.isNotEmpty;
    final firstImageUrl = hasImages ? images.first.url : null;

    return GestureDetector(
      onTap: () {
        if (hasImages) {
          _showFullScreen(context, firstImageUrl!);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: hasImages
            ? Image.network(
          firstImageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        )
            : _buildPlaceholder(),
      ),
    );
  }

  void _showFullScreen(BuildContext context, String url) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.8), // Тот самый серый фон
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return _FullScreenViewer(imageUrl: url);
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      color: Colors.white10,
      child: const Icon(Icons.card_giftcard, color: Colors.white54),
    );
  }
}

class _FullScreenViewer extends StatelessWidget {
  final String imageUrl;

  const _FullScreenViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Закрытие при клике ВЕЗДЕ (включая фон)
      onTap: () => Navigator.pop(context),
      // Закрытие при свайпе вверх
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < -300) {
          Navigator.pop(context);
        }
      },
      behavior: HitTestBehavior.opaque, // Позволяет ловить клики на пустом фоне
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: GestureDetector(
            // Остановка проваливания клика, чтобы нажатие на саму картинку её не закрывало
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}