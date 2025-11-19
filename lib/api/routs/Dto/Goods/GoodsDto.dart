import 'package:flutter/material.dart';

import '../../../../Storage/Search/ImageUrlDto.dart';

class GoodsDto {
  final int? id;

  // Контроллеры для полей
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;

  // Активность товара
  final ValueNotifier<bool> activeNotifier;

  // Список изображений (пока как строки-URL или пути)
  List<ImageUrlDto> images;

  // Дата создания, если нужна для отображения
  final String? createdAt;

  GoodsDto({
    required this.id,
    String? title,
    String? description,
    String? price,
    required bool active,
    required this.images,
    this.createdAt,
  })  : titleController = TextEditingController(text: title ?? ''),
        descriptionController =
        TextEditingController(text: description ?? ''),
        priceController = TextEditingController(text: price ?? ''),
        activeNotifier = ValueNotifier<bool>(active);

  /// Создание из JSON
  factory GoodsDto.fromJson(Map<String, dynamic> json) {
    return GoodsDto(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price']?.toString(),
      active: json['active'] == true || json['active'] == 1,
      images: (json["images"] as List)
          .map((img) => ImageUrlDto.fromJson(img))
          .toList(),
      createdAt: json['created_at'],
    );
  }

  /// Пустой товар (например, для создания)
  factory GoodsDto.empty() {
    return GoodsDto(
      id: null,
      title: '',
      description: '',
      price: '',
      active: true,
      images: [],
      createdAt: null,
    );
  }

  /// В JSON (если будешь отправлять на бек)
  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'title': titleController.text,
      'description': descriptionController.text,
      'price': priceController.text,
      'active': activeNotifier.value,
      // 'images': images,
    };
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    activeNotifier.dispose();
  }
}
