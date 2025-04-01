import 'package:tt_club_ua/config/default.dart';

import '../../../../Storage/Search/ImageUrlDto.dart';
import 'GeneDto.dart';
import 'ModelDto.dart';

class CarDto {
  int id;
  String? name;
  String? vinCode;
  String licensePlate;
  String personalizedLicensePlate;
  String generalLicensePlate;
  GeneDto gene;
  ModelDto model;
  List<ImageUrlDto> imageUrls;
  bool active;

  CarDto({
    required this.id,
    this.name,
    this.vinCode,
    required this.licensePlate,
    required this.personalizedLicensePlate,
    required this.generalLicensePlate,
    required this.gene,
    required this.model,
    required this.imageUrls,
    required this.active,
  });

  factory CarDto.fromJson(Map<String, dynamic> json) {
    return CarDto(
      id: json['id'] ?? 0,
      name: json['name'],
      vinCode: json['vin_code'],
      licensePlate: json['license_plate'] ?? '',
      personalizedLicensePlate: json['personalized_license_plate'] ?? '',
      generalLicensePlate: json['general_license_plate'] ?? '',
      gene: GeneDto.fromJson(json['gene'] ?? {}),
      model: ModelDto.fromJson(json['model'] ?? {}),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((image) => ImageUrlDto.fromJson(image))
              .toList() ??
          [],
      active: json['active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vin_code': vinCode,
      'license_plate': licensePlate,
      'personalized_license_plate': personalizedLicensePlate,
      'general_license_plate': generalLicensePlate,
      'gene': gene.toJson(),
      'model': model.toJson(),
      'active': active ? 1 : 0,
    };
  }
}
