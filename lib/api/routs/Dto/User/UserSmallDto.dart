import 'package:flutter/cupertino.dart';

import '../Car/CarDto.dart';
import '../City/CityDto.dart';

class UserSmallDto {
  Map<String, dynamic> json;
  int id = 0;
  String name;
  String instagram_nickname;
  String profileImage ='';

  UserSmallDto({
    required this.json,
    required this.id,
    required this.name,
    required this.instagram_nickname,
    required this.profileImage
  });

  factory UserSmallDto.fromJson(Map<String, dynamic> json) {
    return UserSmallDto(
      json: json,
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      instagram_nickname: json['instagram_nickname'] ?? '',
      profileImage: json['profile_image'] ?? '',
    );
  }

}
