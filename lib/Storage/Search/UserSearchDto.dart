import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:tt_club_ua/config/default.dart';

class UserSearchDto {
  Map<String, dynamic> json;
  NetworkImage? profileImage;
  String name;
  String email;
  String phone;
  String telegramNickname;
  String instagramNickname;

  // List<int>? cities;//TODO DTOS
  String birthDateText;
  DateTime? birthDate;
  String clubEntryDateText;
  DateTime? clubEntryDate;
  String? occupationDescription;
  String? carsText;
  String? citiesText;

  // UserDTO(this.list);

  UserSearchDto.fromJson(Map<String, dynamic> json)
      : json = json,
        email = json['email'] ?? "Не вказано",
        phone = json["phone"] ?? "Не вказано",
        telegramNickname = json['telegram_nickname'] ?? "Не вказано",
        instagramNickname = json['instagram_nickname'] ?? "Не вказано",
        // _cities =
        //     json['cities'] != null ? List<int>.from(json['cities']) : null,
        // birthDate = json['birth_date'] != null
        //     ? DateTime.parse(json['birthDate'])
        //     : null,
        birthDateText = json["birth_date"] ?? "Не вказано",
        // clubEntryDate = json['club_entry_date'] != null
        //     ? DateTime.parse(json['clubEntryDate'])
        //     : null,
        clubEntryDateText = json["club_entry_date"] ?? "Не вказано",
        occupationDescription = json['occupation_description'] ?? "Не вказано",
        name = json['name'] ?? "Ім'я невідоме",
        profileImage = json["profile_image"] != null
            ? NetworkImage(json["profile_image"])
            : null,
        carsText = (json["cars"] != null && json["cars"].isNotEmpty)
            ? json["cars"].map((c) {
                final gene = c["gene"]?["name"] ?? "Марка невідома";
                final model = c["model"]?["name"] ?? "Модель невідома";
                final plate = c["general_license_plate"] ?? "Номер невідомий";
                return "$model $gene ($plate)";
              }).join(" | ")
            : "Авто не вказано",
        citiesText = (json["cities"] != null && json["cities"].isNotEmpty)
            ? json["cities"].map((c) => c["name"]).join(", ")
            : "Міста не вказані";
}
