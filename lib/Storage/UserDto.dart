import 'package:intl/intl.dart';
import 'package:tt_club_ua/config/default.dart';

class UserDTO {
  String? email;
  String? phone;
  String? telegramNickname;
  String? instagramNickname;
  List<int>? cities;
  DateTime? birthDate;
  DateTime? clubEntryDate;
  String? occupationDescription;
  String? name;

  UserDTO({
    this.email,
    this.phone,
    this.telegramNickname,
    this.instagramNickname,
    this.cities,
    this.birthDate,
    this.clubEntryDate,
    this.occupationDescription,
    this.name,
  });

  /// Фабричный метод для создания объекта из JSON
  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      telegramNickname: json['telegram_nickname'] as String?,
      instagramNickname: json['instagram_nickname'] as String?,
      cities: (json['cities'] as List?)?.map((e) => e['id'] as int).toList(),
      birthDate: json['birth_date'] != null
          ? DateFormat(DATE_FORMAT_DEFAULT).parse(json['birth_date'])
          : null,
      clubEntryDate: json['club_entry_date'] != null
          ? DateFormat(DATE_FORMAT_DEFAULT).parse(json['club_entry_date'])
          : null,
      occupationDescription: json['occupation_description'] as String?,
      name: json['name'] as String?,
    );
  }

  /// Метод для конвертации объекта в JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'telegram_nickname': telegramNickname,
      'instagram_nickname': instagramNickname,
      'cities': cities ?? [],
      'birth_date': birthDate != null
          ? DateFormat(DATE_FORMAT_DEFAULT_SEND).format(birthDate!)
          : '',
      'club_entry_date': clubEntryDate != null
          ? DateFormat(DATE_FORMAT_DEFAULT_SEND).format(clubEntryDate!)
          : '',
      'occupation_description': occupationDescription,
    };
  }
}
