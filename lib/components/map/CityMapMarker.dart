import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../api/routs/Dto/City/CityMapPointDto.dart';
import '../../config/default.dart';

/// Shared visual for a city map marker: an avatar circle for a single member
/// with a photo, or a branded count badge otherwise (FR-006-FR-008).
/// Used directly as a widget in the Android (flutter_map) marker layer, and
/// rasterized into an image for the iOS (apple_maps_flutter) annotation icon.
///
/// For the iOS rasterization path (see CityUsersMapScreen.ios.dart), pass
/// [decodedAvatarOverride] with an already-*decoded* [ui.Image]: the
/// off-screen render used to build the annotation icon happens
/// synchronously, so neither a live [CachedNetworkImage] (still downloading)
/// nor `Image.memory` (still decoding — decoding is itself async) would be
/// ready in time and would always render as the fallback.
class CityMapMarker extends StatelessWidget {
  final CityMapPointDto point;
  final double size;
  final ui.Image? decodedAvatarOverride;

  const CityMapMarker({
    super.key,
    required this.point,
    this.size = 44,
    this.decodedAvatarOverride,
  });

  @override
  Widget build(BuildContext context) {
    if (point.showsAvatar) {
      return _AvatarMarker(
        url: point.avatarUrl!,
        size: size,
        decodedImage: decodedAvatarOverride,
      );
    }

    return _CountBadgeMarker(count: point.usersCount, size: size);
  }
}

class _AvatarMarker extends StatelessWidget {
  final String url;
  final double size;
  final ui.Image? decodedImage;

  const _AvatarMarker({required this.url, required this.size, this.decodedImage});

  @override
  Widget build(BuildContext context) {
    return _MarkerShell(
      size: size,
      child: ClipOval(
        child: decodedImage != null
            ? RawImage(
                image: decodedImage,
                width: size,
                height: size,
                fit: BoxFit.cover,
              )
            : CachedNetworkImage(
                imageUrl: url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const _FallbackCountLabel(count: 1),
                placeholder: (context, url) => const _FallbackCountLabel(count: 1),
              ),
      ),
    );
  }
}

class _CountBadgeMarker extends StatelessWidget {
  final int count;
  final double size;

  const _CountBadgeMarker({required this.count, required this.size});

  @override
  Widget build(BuildContext context) {
    return _MarkerShell(
      size: size,
      child: _FallbackCountLabel(count: count),
    );
  }
}

class _FallbackCountLabel extends StatelessWidget {
  final int count;

  const _FallbackCountLabel({required this.count});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$count',
        style: TTTextStyle.title18.copyWith(fontSize: 16),
      ),
    );
  }
}

class _MarkerShell extends StatelessWidget {
  final double size;
  final Widget child;

  const _MarkerShell({required this.size, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: TTColors.card,
        border: Border.all(color: TTColors.text, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}
