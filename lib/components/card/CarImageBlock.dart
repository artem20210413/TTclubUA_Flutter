import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/components/viewers/FullImageViewer.dart';

class CarImageBlock extends StatelessWidget {
  final String? imageUrl;
  final bool isActiveUser;
  final double height;
  final double borderRadius;
  final String? uniqueKey;

  /// Optional tap override. When provided (e.g. by [ImagesCarousel] to open the
  /// collection-aware fullscreen gallery) it replaces the default single-image
  /// [FullImageViewer]. Non-carousel callers keep the default behavior.
  final VoidCallback? onTap;

  const CarImageBlock({
    super.key,
    this.uniqueKey,
    required this.imageUrl,
    this.isActiveUser = true,
    this.height = 200,
    this.borderRadius = 32,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else if (imageUrl != null) {
          FullImageViewer.show(context, imageUrl!);
        }
      },

      child: Hero(
        tag: uniqueKey ?? imageUrl!,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(borderRadius),
            bottom: Radius.circular(borderRadius),
          ),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              isActiveUser ? Colors.transparent : Colors.grey,
              isActiveUser ? BlendMode.srcOver : BlendMode.saturation,
            ),
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    height: height,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: height,
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                            color: Colors.white),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: height,
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.white54, size: 40),
                    ),
                  )
                : Container(
                    height: height,
                    width: double.infinity,
                    color: TTColors.background_second,
                    child: const Icon(Icons.image, color: Colors.white30),
                  ),
          ),
        ),
      ),
    );
  }
}
