import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/Search/ImageUrlDto.dart';

class EventTypeDto {
  final int? id;
  final String name;
  final String? image;
  final int sort;

  EventTypeDto({
    required this.id,
    required this.name,
    required this.sort,
    this.image,
  });

  factory EventTypeDto.fromJson(Map<String, dynamic> json) {
    return EventTypeDto(
      id: json['id'],
      name: json['name'] ?? '',
      sort: json['sort'] ?? 0,
      image: json['image'],
    );
  }

  factory EventTypeDto.empty() {
    return EventTypeDto(id: 0, name: '', sort: 0, image: null);
  }
}
