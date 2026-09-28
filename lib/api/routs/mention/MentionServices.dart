import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:tt_club_ua/api/routs/Dto/MentionLocationPointDto.dart';
import 'package:tt_club_ua/api/routs/root.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'mention.dart';

/// Pulls the actual item list out of a decoded JSON response body, tolerating
/// a few common backend wrapper shapes: a bare array, `{"data": [...]}`,
/// Laravel-style pagination (`{"data": {"data": [...]}}`), or a named nested
/// key such as `{"data": {"locations": [...]}}`.
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

class MentionServices {
  /// Returns null on failure (network error / non-2xx) so callers can show
  /// their own non-blocking retry UI instead of the default error toast.
  static Future<List<MentionLocationPointDto>?> fetchMentionLocations(
      BuildContext context) async {
    try {
      final token = await UserStorage.getToken();
      final res = await GET_MENTION_LOCATIONS(token);

      final isSuccess = await CHECK_API(res, context, isEx: false);
      if (!isSuccess) return null;

      final decodedBody = jsonDecode(res.body);
      final list = _extractList(decodedBody);

      return list
          .map((json) => MentionLocationPointDto.fromJson(json))
          .toList();
    } catch (e) {
      print('fetchMentionLocations exception: $e');
      return null;
    }
  }
}
