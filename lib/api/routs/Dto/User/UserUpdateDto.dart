import 'package:flutter/cupertino.dart';

import '../Car/CarDto.dart';
import '../City/CityDto.dart';

class UserUpdateDto {
  Map<String, dynamic> json;
  int id;

  // Контроллеры для полей, которые могут редактироваться
  TextEditingController nameController = TextEditingController();
  TextEditingController telegramNicknameController = TextEditingController();
  TextEditingController instagramNicknameController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  TextEditingController occupationDescriptionController =
      TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool active;
  String profileImage;
  List<CityDto> cities;
  List<CarDto> cars;

  UserUpdateDto.fromJson(this.json)
      : active = json['active'] ?? false,
        id = json['id'] ?? '',
        profileImage = json['profile_image'] ?? '',
        cities = (json['cities'] as List<dynamic>?)
                ?.map((city) => CityDto.fromJson(city))
                .toList() ??
            [],
        cars = (json['cars'] as List<dynamic>?)
                ?.map((car) => CarDto.fromJson(car))
                .toList() ??
            [] {
    nameController.text = json['name'] ?? '';
    telegramNicknameController.text = json['telegram_nickname'] ?? '';
    instagramNicknameController.text = json['instagram_nickname'] ?? '';
    birthDateController.text = json['birth_date'] ?? '';
    occupationDescriptionController.text = json['occupation_description'] ?? '';
    emailController.text = json['email'] ?? '';
    phoneController.text = json['phone'] ?? '';
  }

  // Метод для получения JSON обратно
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nameController.text,
      'telegram_nickname': telegramNicknameController.text,
      'instagram_nickname': instagramNicknameController.text,
      'birth_date': birthDateController.text,
      'occupation_description': occupationDescriptionController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'active': active,
      // 'profile_image': profileImage,
      'cities': cities.map((city) => city.id).toList(),
      // 'cars': cars.map((car) => car.toJson()).toList(),
    };
  }
}
