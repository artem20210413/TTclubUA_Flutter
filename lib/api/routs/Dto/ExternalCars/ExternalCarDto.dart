import '../../../../Storage/Search/ImageUrlDto.dart';
import '../../../../Storage/Search/UserSearchDto.dart';

class ExternalCarDto {
  final int id;
  final String title;
  final String? description;
  final double priceUsd;
  final String cityName;
  final String cityLocative;
  final String regionName;
  final String markName;
  final String modelName;
  final String subCategory;
  final String race;
  final String fuelName;
  final String driveName;
  final String equipmentName;
  final String generationName;
  final String gearboxName;
  final String modificationName;
  final int year;
  final String linkToView;
  final CarColor? color;
  final List<ImageUrlDto> images;
  final UserSearchDto? user;
  final DateTime? createdAt;

  ExternalCarDto({
    required this.id,
    required this.title,
    this.description,
    required this.priceUsd,
    required this.cityName,
    required this.cityLocative,
    required this.regionName,
    required this.markName,
    required this.modelName,
    required this.subCategory,
    required this.race,
    required this.fuelName,
    required this.driveName,
    required this.equipmentName,
    required this.generationName,
    required this.gearboxName,
    required this.modificationName,
    required this.year,
    required this.linkToView,
    this.color,
    required this.images,
    this.user,
    this.createdAt,
  });

  factory ExternalCarDto.fromJson(Map<String, dynamic> json) {
    return ExternalCarDto(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      priceUsd: double.tryParse(json['price_usd']?.toString() ?? '0') ?? 0,
      cityName: json['city_name'] ?? '',
      cityLocative: json['cityLocative'] ?? '',
      // Додаємо .toString() і перевірку на null для безпеки
      regionName: json['regionName']?.toString() ?? '',
      markName: json['mark_name']?.toString() ?? '',
      modelName: json['model_name']?.toString() ?? '',
      subCategory: json['sub_category']?.toString() ?? '',
      race: json['race']?.toString() ?? '',
      fuelName: json['fuelName']?.toString() ?? '',
      driveName: json['driveName']?.toString() ?? '',
      equipmentName: json['equipmentName']?.toString() ?? '',
      generationName: json['generationName']?.toString() ?? '',
      // 👈 Тут була помилка
      gearboxName: json['gearboxName']?.toString() ?? '',
      modificationName: json['modificationName']?.toString() ?? '',
      year: json['year'] ?? 0,
      linkToView: json['linkToView'] ?? '',
      color: (json['color'] is Map<String, dynamic>)
          ? CarColor.fromJson(json['color'])
          : null,
      images: (json['images'] as List?)
              ?.map((img) => ImageUrlDto.fromJson(img))
              .toList() ??
          [],
      user: json['user'] != null ? UserSearchDto.fromJson(json['user']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

class CarColor {
  final String eng;
  final String hex;
  final String name;

  CarColor({required this.eng, required this.hex, required this.name});

  factory CarColor.fromJson(Map<String, dynamic> json) {
    return CarColor(
      eng: json['eng'] ?? '',
      hex: json['hex'] ?? '#000000',
      name: json['name'] ?? '',
    );
  }
}
