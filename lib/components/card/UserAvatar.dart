import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

import '../viewers/FullImageViewer.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final String? uniqueKey;

  const UserAvatar({
    super.key,
    required this.name,
    this.uniqueKey,
    this.imageUrl,
    this.radius = 25,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCustomImage =
        imageUrl != null && imageUrl != USER_PROFILE_IMAGE_DEFAULT;

    final String displayUrl = (imageUrl != null && imageUrl!.isNotEmpty)
        ? imageUrl!
        : USER_PROFILE_IMAGE_DEFAULT;

    return GestureDetector(
      onTap: () =>
          hasCustomImage ? FullImageViewer.show(context, displayUrl) : null,
      child: Hero(
        tag: uniqueKey ?? name,
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: !hasCustomImage
                ? Border.all(
                    color: TTColors.text,
                    width: 1,
                  )
                : null,
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundImage: hasCustomImage ? NetworkImage(displayUrl!) : null,
            backgroundColor: TTColors.card,
            child: !hasCustomImage
                ? Text(
                    name.characters.first,
                    style: TTTextStyle.title.copyWith(fontSize: radius * 0.8),
                    // const TextStyle(
                    //   color: Colors.white,
                    //   fontWeight: FontWeight.w500,
                    // ),
                  )
                : null,
          ),
        ),
      ),
    );

    // return GestureDetector(
    //   onTap: () => FullImageViewer.show(context, displayUrl),
    //   child: Hero(
    //     tag: displayUrl,
    //     child: ClipRRect(
    //       borderRadius: BorderRadius.vertical(
    //         top: Radius.circular(borderRadius),
    //         bottom: Radius.circular(borderRadius),
    //       ),
    //       child: ColorFiltered(
    //         colorFilter: ColorFilter.mode(
    //           isActiveUser ? Colors.transparent : Colors.grey,
    //           isActiveUser ? BlendMode.srcOver : BlendMode.saturation,
    //         ),
    //         child: Image.network(
    //           displayUrl,
    //           height: height,
    //           width: double.infinity,
    //           fit: BoxFit.cover,
    //           loadingBuilder: (context, child, loadingProgress) {
    //             if (loadingProgress == null) return child;
    //             return Container(
    //               height: height,
    //               color: Colors.black12,
    //               alignment: Alignment.center,
    //               child: const CircularProgressIndicator(color: Colors.white),
    //             );
    //           },
    //           errorBuilder: (_, __, ___) => Container(
    //             height: height,
    //             color: Colors.black12,
    //             alignment: Alignment.center,
    //             child: const Icon(Icons.image_not_supported,
    //                 color: Colors.white54, size: 40),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
