import 'package:tt_club_ua/Storage/Search/ImageUrlDto.dart';

class CalendarItemDto {
  final String type;        // "birthday" или "event_ttclubua"
  final String id;
  final int model_id;

  final String title;
  final String description;

  final DateTime? date;
  final String? time;

  final String? place;
  final String? googleMaps;

  // картинки — могут быть строками или объектами
  final List<String> images;
  final List<ImageUrlDto> dtoImages;

  CalendarItemDto({
    required this.type,
    required this.id,
    required this.model_id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.place,
    required this.googleMaps,
    required this.images,
    required this.dtoImages,
  });

  // ---------- FROM JSON ----------
  factory CalendarItemDto.fromJson(Map<String, dynamic> json) {
    // Обработка даты
    DateTime? parsedDate;
    if (json['date'] != null && json['date'].toString().isNotEmpty) {
      parsedDate = DateTime.tryParse(json['date']);
    }

    // парсим картинки (строки или объекты)
    final rawImages = json['images'] as List<dynamic>? ?? [];

    final parsedImages = rawImages.map<String>((img) {
      if (img is String) return img;
      if (img is Map<String, dynamic>) return img['url'] ?? '';
      return '';
    }).toList();

    return CalendarItemDto(
      type: json['type'] ?? '',
      id: json['id'] ?? '',
      model_id: json['model_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: parsedDate,
      time: json['time'],
      place: json['place'],
      googleMaps: json['google_maps'],
      images: parsedImages,
      dtoImages: (json['images'] as List<dynamic>?)
          ?.map((e) => ImageUrlDto.fromJson(e))
          .toList() ??
          [],
    );
  }

  // ---------- EMPTY ----------
  factory CalendarItemDto.empty() {
    return CalendarItemDto(
      type: '',
      id: '',
      model_id: 0,
      title: '',
      description: '',
      date: null,
      time: null,
      place: null,
      googleMaps: null,
      images: [],
      dtoImages: [],
    );
  }
}
