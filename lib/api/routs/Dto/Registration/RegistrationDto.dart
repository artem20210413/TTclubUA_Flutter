import 'package:flutter/cupertino.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../../../Storage/Search/ImageUrlDto.dart';

class RegistrationDto {
  Map<String, dynamic> json;
  int id;
  String name;
  String phone;
  NetworkImage userImage;
  List<ImageUrlDto> carImages;

  RegistrationDto({
    required this.json,
    required this.id,
    required this.name,
    required this.phone,
    required this.userImage,
    required this.carImages,
  });

  factory RegistrationDto.fromJson(Map<String, dynamic> json) {
    return RegistrationDto(
      json: json,
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      carImages: (json['car_images'] as List<dynamic>?)
              ?.map((image) => ImageUrlDto.fromJson(image))
              .toList() ??
          [],
      userImage:
          NetworkImage(json['profile_image'] ?? USER_PROFILE_IMAGE_DEFAULT),
    );
  }
}
