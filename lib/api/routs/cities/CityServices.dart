import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:tt_club_ua/api/routs/Dto/City/CityMapPointDto.dart';
import 'package:tt_club_ua/api/routs/Dto/City/CityMemberDto.dart';
import 'package:tt_club_ua/api/routs/root.dart';
import 'package:tt_club_ua/Storage/CityDto.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'city.dart';

/// Pulls the actual item list out of a decoded JSON response body, tolerating
/// a few common backend wrapper shapes: a bare array, `{"data": [...]}`,
/// Laravel-style pagination (`{"data": {"data": [...]}}`), or a named nested
/// key such as `{"data": {"cities": [...]}}` / `{"data": {"users": [...]}}`.
List<dynamic> _extractList(dynamic decodedBody) {
  if (decodedBody is List) return decodedBody;

  if (decodedBody is Map<String, dynamic>) {
    final data = decodedBody['data'];
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      if (data['data'] is List) return data['data'] as List;
      for (final value in data.values) {
        if (value is List) return value;
      }
    }
  }

  return const [];
}

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

  /// Returns null on failure (network error / non-2xx) so callers can show
  /// their own non-blocking retry UI instead of the default error toast.
  static Future<List<CityMapPointDto>?> fetchCityMapPoints(
      BuildContext context) async {
    try {
      final token = await UserStorage.getToken();
      final res = await GET_CITIES_MAP(token);

      final isSuccess = await CHECK_API(res, context, isEx: false);
      if (!isSuccess) {
        // TODO: remove once GET api/cities/map is confirmed live on the backend.
        print(
            'fetchCityMapPoints failed: ${res.statusCode} ${res.request?.url} body=${res.body}');
        return null;
      }

      final decodedBody = jsonDecode(res.body);
      final list = _extractList(decodedBody);

      return list.map((json) => CityMapPointDto.fromJson(json)).toList();
    } catch (e) {
      print('fetchCityMapPoints exception: $e');
      return null;
    }
  }

  /// Returns null on failure (network error / non-2xx) so callers can show
  /// their own non-blocking retry UI scoped to the failed page.
  static Future<List<CityMemberDto>?> fetchCityMembers(
      BuildContext context, int cityId,
      {int page = 1}) async {
    try {
      final token = await UserStorage.getToken();
      final res = await GET_CITY_USERS(token, cityId, page: page);

      final isSuccess = await CHECK_API(res, context, isEx: false);
      if (!isSuccess) {
        // TODO: remove once GET api/cities/{id}/users is confirmed live on the backend.
        print(
            'fetchCityMembers failed: ${res.statusCode} ${res.request?.url} body=${res.body}');
        return null;
      }

      final decodedBody = jsonDecode(res.body);
      final list = _extractList(decodedBody);

      return list.map((json) => CityMemberDto.fromJson(json)).toList();
    } catch (e) {
      print('fetchCityMembers exception: $e');
      return null;
    }
  }
}
