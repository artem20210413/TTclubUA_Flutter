import 'dart:ffi';

import 'package:flutter/cupertino.dart';

class ImageUrlDto {
  final int id;
  final String url;
  final NetworkImage networkImage;

  ImageUrlDto({
    required this.id,
    required this.url,
    required this.networkImage,
  });

  // Создание объекта из JSON
  factory ImageUrlDto.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['url'] ?? '';
    return ImageUrlDto(
      id: json['id'] ?? 0,
      url: imageUrl,
      networkImage: NetworkImage(imageUrl),
    );
  }
}
