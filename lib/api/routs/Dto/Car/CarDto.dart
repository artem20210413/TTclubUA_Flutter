import 'package:tt_club_ua/config/default.dart';

import '../../../../Storage/Search/ImageUrlDto.dart';
import 'GeneDto.dart';
import 'ModelDto.dart';

import 'package:flutter/material.dart';

class CarDto {
  final int id;
  final TextEditingController nameController;
  final TextEditingController vinCodeController;
  final TextEditingController licensePlateController;
  final TextEditingController personalizedLicensePlateController;
  final String generalLicensePlate;
  final ValueNotifier<bool> activeNotifier;

  GeneDto gene;
  ModelDto model;
  List<ImageUrlDto> imageUrls;

  CarDto({
    required this.id,
    String? name,
    String? vinCode,
    required String licensePlate,
    required String personalizedLicensePlate,
    required this.generalLicensePlate,
    required bool active,
    required this.gene,
    required this.model,
    required this.imageUrls,
  })  : nameController = TextEditingController(text: name ?? ''),
        vinCodeController = TextEditingController(text: vinCode ?? ''),
        licensePlateController = TextEditingController(text: licensePlate),
        personalizedLicensePlateController =
            TextEditingController(text: personalizedLicensePlate),
        activeNotifier = ValueNotifier<bool>(active);

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

  factory CarDto.empty() {
    return CarDto(
      id: 0,
      name: '',
      vinCode: '',
      licensePlate: '',
      personalizedLicensePlate: '',
      generalLicensePlate: '',
      gene: GeneDto.empty(),
      model: ModelDto.empty(),
      imageUrls: [],
      active: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'name': nameController.text,
      'vin_code': vinCodeController.text,
      'license_plate': licensePlateController.text,
      'personalized_license_plate': personalizedLicensePlateController.text,
      'gene': gene.toJson(),
      'model': model.toJson(),
      'active': activeNotifier.value ? 1 : 0,
    };
  }

  void dispose() {
    nameController.dispose();
    vinCodeController.dispose();
    licensePlateController.dispose();
    personalizedLicensePlateController.dispose();
    activeNotifier.dispose();
  }
}

