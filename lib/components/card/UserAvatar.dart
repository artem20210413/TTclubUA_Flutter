import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;

  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 25,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCustomImage =
        imageUrl != null && imageUrl != USER_PROFILE_IMAGE_DEFAULT;

    return Container(
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
          backgroundImage: hasCustomImage ? NetworkImage(imageUrl! ) : null,
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
        ));
  }
}
