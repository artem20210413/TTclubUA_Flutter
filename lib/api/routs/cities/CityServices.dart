import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:tt_club_ua/api/routs/root.dart';
import 'package:tt_club_ua/Storage/CityDto.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'city.dart';

class CityServices {
  static Future<List<CityDTO>> getAllCities(BuildContext context) async {
    final token = await UserStorage.getToken();
    final resCities = await GET_CITIES(token);

    final isSuccessCities = await CHECK_API(resCities, context);
    if (!isSuccessCities) return [];

    final decodedBody = jsonDecode(resCities.body);

    return ((decodedBody['data']['cities'] ?? []) as List)
        .map((json) => CityDTO.fromJson(json))
        .toList();
  }
}
