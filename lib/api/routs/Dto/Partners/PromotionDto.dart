import 'package:flutter/material.dart';
import '../../../../Storage/Search/ImageUrlDto.dart';

class PromotionDto {
  final int? id;
  final int partnerId;

  // Controllers
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController discountValueController;
  final TextEditingController promoCodeController;
  final TextEditingController priorityController;

  // Flags
  final ValueNotifier<bool> activeNotifier;
  final ValueNotifier<bool> exclusiveNotifier;

  // Dates
  DateTime? startDate;
  DateTime? endDate;

  // Images
  List<ImageUrlDto> images;

  final String? createdAt;
  final String? updatedAt;

  PromotionDto({
    required this.id,
    required this.partnerId,
    String? title,
    String? description,
    String? discountValue,
    String? promoCode,
    String? priority,
    required bool isActive,
    required bool isExclusive,
    required this.startDate,
    required this.endDate,
    required this.images,
    this.createdAt,
    this.updatedAt,
  })  : titleController = TextEditingController(text: title ?? ''),
        descriptionController =
        TextEditingController(text: description ?? ''),
        discountValueController =
        TextEditingController(text: discountValue ?? ''),
        promoCodeController =
        TextEditingController(text: promoCode ?? ''),
        priorityController =
        TextEditingController(text: priority ?? '0'),
        activeNotifier = ValueNotifier<bool>(isActive),
        exclusiveNotifier = ValueNotifier<bool>(isExclusive);

  /// ---------- FROM JSON ----------
  factory PromotionDto.fromJson(Map<String, dynamic> json) {
    return PromotionDto(
      id: json['id'],
      partnerId: json['partner_id'],
      title: json['promo_title'],
      description: json['promo_description'],
      discountValue: json['discount_value'],
      promoCode: json['promo_code'],
      priority: json['priority']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      isExclusive: json['is_exclusive'] == true || json['is_exclusive'] == 1,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'])
          : null,
      images: (json['photos'] as List? ?? [])
          .map((e) => ImageUrlDto.fromJson(e))
          .toList(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  /// ---------- EMPTY (создание) ----------
  factory PromotionDto.empty({required int partnerId}) {
    return PromotionDto(
      id: null,
      partnerId: partnerId,
      title: '',
      description: '',
      discountValue: '',
      promoCode: '',
      priority: '0',
      isActive: true,
      isExclusive: false,
      startDate: null,
      endDate: null,
      images: [],
      createdAt: null,
      updatedAt: null,
    );
  }

  /// ---------- TO JSON ----------
  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'partner_id': partnerId,
      'promo_title': titleController.text,
      'promo_description': descriptionController.text,
      'discount_value': discountValueController.text,
      'promo_code': promoCodeController.text,
      'priority': priorityController.text,
      'is_active': activeNotifier.value ? 1 : 0,
      'is_exclusive': exclusiveNotifier.value ? 1 : 0,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }

  /// ---------- DISPOSE ----------
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    discountValueController.dispose();
    promoCodeController.dispose();
    priorityController.dispose();
    activeNotifier.dispose();
    exclusiveNotifier.dispose();
  }
}
