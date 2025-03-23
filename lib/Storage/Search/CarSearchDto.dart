import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:tt_club_ua/Storage/Search/ImageUrlDto.dart';
import 'package:tt_club_ua/Storage/Search/UserSearchDto.dart';
import 'package:tt_club_ua/config/default.dart';

class CarSearchDto {
  Map<String, dynamic> json;
  String id;
  String name;
  String vinCode;
  String licensePlate;
  String personalizedLicensePlate;
  String generalLicensePlate;
  String geneName;
  UserSearchDto user;
  String modelName;
  List<ImageUrlDto> images;

  // DateTime? birthDate;
  // String clubEntryDateText;
  // DateTime? clubEntryDate;
  // String? occupationDescription;
  // String? carsText;
  // String? citiesText;

  // UserDTO(this.list);

  String getFullLicensePlate() {
    return "${licensePlate} ${personalizedLicensePlate}";
  }

  CarSearchDto.fromJson(Map<String, dynamic> json)
      : json = json,
        id = json['id'].toString() ?? '0',
        name = json['name'] ?? "Не вказано",
        vinCode = json['vin_code'] ?? "Не вказано",
        licensePlate = json['license_plate'] ?? "-",
        personalizedLicensePlate = json['personalized_license_plate'] ?? "-",
        generalLicensePlate = json['general_license_plate'] ?? "-",
        geneName = json['gene']['name'] ?? "Не вказано",
        modelName = json['model']['name'] ?? "Не вказано",
        images = (json["imageUrls"] as List)
            .map((img) => ImageUrlDto.fromJson(img))
            .toList(),
        user = UserSearchDto.fromJson(json['user'] ?? {});
}
