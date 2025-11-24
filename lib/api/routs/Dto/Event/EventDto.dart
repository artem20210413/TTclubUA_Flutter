import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/Search/ImageUrlDto.dart';

import 'EventTypeDto.dart';

class EventDto {
  final int? id;

  // Controllers
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController placeController;
  final TextEditingController googleMapsController;

  // Дата заходу
  DateTime? eventDate;

  // active
  final ValueNotifier<bool> activeNotifier;

  // images
  List<ImageUrlDto> images;

  // event type
  EventTypeDto eventType;

  final String? createdAt;

  EventDto({
    required this.id,
    required String title,
    required String description,
    required String place,
    required String googleMapsUrl,
    required this.eventDate,
    required this.images,
    required bool active,
    required this.eventType,
    required this.createdAt,
  })  : titleController = TextEditingController(text: title),
        descriptionController = TextEditingController(text: description),
        placeController = TextEditingController(text: place),
        googleMapsController = TextEditingController(text: googleMapsUrl),
        activeNotifier = ValueNotifier<bool>(active);

  // ---------- FROM JSON ----------
  factory EventDto.fromJson(Map<String, dynamic> json) {
    return EventDto(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      place: json['place'] ?? '',
      googleMapsUrl: json['google_maps_url'] ?? '',
      eventDate: json['event_date'] != null
          ? DateTime.tryParse(json['event_date'])
          : null,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => ImageUrlDto.fromJson(e))
              .toList() ??
          [],
      active: json['active'] == true,
      eventType: json['event_type'] != null
          ? EventTypeDto.fromJson(json['event_type'])
          : EventTypeDto.empty(),
      createdAt: json['created_at'],
    );
  }

  // ---------- EMPTY ----------
  factory EventDto.empty() {
    return EventDto(
      id: null,
      title: '',
      description: '',
      place: '',
      googleMapsUrl: '',
      eventDate: null,
      images: [],
      active: true,
      eventType: EventTypeDto.empty(),
      createdAt: null,
    );
  }

  // ---------- TO JSON ----------
  Map<String, dynamic> toJson() {
    return {
      'title': titleController.text,
      'description': descriptionController.text,
      'place': placeController.text,
      'google_maps_url': googleMapsController.text,
      'event_date': eventDate?.toIso8601String(),
      'active': activeNotifier.value,
      'event_type_id': eventType.id,
      // картинки отправлять не нужно (их отдельным API)
    };
  }

  // ---------- DISPOSE ----------
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    placeController.dispose();
    googleMapsController.dispose();
    activeNotifier.dispose();
  }
}
