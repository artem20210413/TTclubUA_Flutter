import 'package:flutter/material.dart';

import '../../../../Storage/Search/ImageUrlDto.dart';

class PartnerDto {
  final int? id;

  // Controllers
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController websiteUrlController;
  final TextEditingController instagramUrlController;
  final TextEditingController googleMapsUrlController;
  final TextEditingController priorityController;
  final bool hasPromotions;
  final bool hasPromotionsActual;

  // Dates
  DateTime? startDate;
  DateTime? endDate;
  List<ImageUrlDto> images;

  // Active
  final ValueNotifier<bool> activeNotifier;

  final String? createdAt;

  PartnerDto({
    required this.id,
    String? title,
    String? description,
    String? websiteUrl,
    String? instagramUrl,
    String? googleMapsUrl,
    String? priority,
    required bool active,
    this.hasPromotions = false,
    this.hasPromotionsActual = false,
    required this.images,
    required this.startDate,
    required this.endDate,
    this.createdAt,
  })  : titleController = TextEditingController(text: title ?? ''),
        descriptionController = TextEditingController(text: description ?? ''),
        websiteUrlController = TextEditingController(text: websiteUrl ?? ''),
        instagramUrlController =
            TextEditingController(text: instagramUrl ?? ''),
        googleMapsUrlController =
            TextEditingController(text: googleMapsUrl ?? ''),
        priorityController = TextEditingController(text: priority ?? '0'),
        activeNotifier = ValueNotifier<bool>(active);

  /// ---------- FROM JSON ----------
  factory PartnerDto.fromJson(Map<String, dynamic> json) {
    return PartnerDto(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      websiteUrl: json['website_url'],
      instagramUrl: json['instagram_url'],
      googleMapsUrl: json['google_maps_url'],
      priority: json['priority']?.toString(),
      hasPromotions: json['has_promotions'],
      hasPromotionsActual: json['has_promotions_actual'],
      active: json['is_active'] == true || json['is_active'] == 1,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'])
          : null,
      endDate:
          json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      images: (json["photos"] as List)
          .map((img) => ImageUrlDto.fromJson(img))
          .toList(),
      createdAt: json['created_at'],
    );
  }

  /// ---------- EMPTY (для создания) ----------
  factory PartnerDto.empty() {
    return PartnerDto(
      id: null,
      title: '',
      description: '',
      websiteUrl: '',
      instagramUrl: '',
      googleMapsUrl: '',
      priority: '0',
      active: true,
      startDate: null,
      endDate: null,
      createdAt: null,
      images: [],
    );
  }

  /// ---------- TO JSON (для API) ----------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': titleController.text,
      'description': descriptionController.text,
      'website_url': websiteUrlController.text,
      'instagram_url': instagramUrlController.text,
      'google_maps_url': googleMapsUrlController.text,
      'priority': priorityController.text,
      'is_active': activeNotifier.value ? 1 : 0,
      'start_date': startDate?.toIso8601String().split('T').first,
      'end_date': endDate?.toIso8601String().split('T').first,
    };
  }

  /// ---------- DISPOSE ----------
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    websiteUrlController.dispose();
    instagramUrlController.dispose();
    googleMapsUrlController.dispose();
    priorityController.dispose();
    activeNotifier.dispose();
  }
}
