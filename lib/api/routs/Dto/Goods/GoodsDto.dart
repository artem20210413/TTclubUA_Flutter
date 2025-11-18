import 'package:flutter/material.dart';

import '../../../../Storage/Search/ImageUrlDto.dart';

class GoodsDto {
  final int? id;

  // Контроллеры для полей
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController placeController;

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
    String? place,
    required bool active,
    required this.images,
    this.createdAt,
  })  : titleController = TextEditingController(text: title ?? ''),
        descriptionController =
        TextEditingController(text: description ?? ''),
        placeController = TextEditingController(text: place ?? ''),
        activeNotifier = ValueNotifier<bool>(active);

  /// Создание из JSON
  factory GoodsDto.fromJson(Map<String, dynamic> json) {
    return GoodsDto(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      place: json['place'],
      active: json['active'] == true || json['active'] == 1,
      images: (json["images"] as List)
          .map((img) => ImageUrlDto.fromJson(img))
          .toList(),
      // images: (json['images'] as List<dynamic>?)
      //     ?.map((e) => e.toString())
      //     .toList() ??
      //     [],
      createdAt: json['created_at'],
    );
  }

  /// Пустой товар (например, для создания)
  factory GoodsDto.empty() {
    return GoodsDto(
      id: null,
      title: '',
      description: '',
      place: '',
      active: true,
      images: [],
      createdAt: null,
    );
  }

  /// В JSON (если будешь отправлять на бек)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': titleController.text,
      'description': descriptionController.text,
      'place': placeController.text,
      'active': activeNotifier.value,
      'images': images,
    };
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    placeController.dispose();
    activeNotifier.dispose();
  }
}
