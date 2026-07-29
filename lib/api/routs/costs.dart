import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'package:tt_club_ua/api/routs/Dto/Costs/CostsDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Finance/FinanceDto.dart';
import 'dart:convert';

import 'package:tt_club_ua/api/routs/Dto/User/UserUpdateDto.dart';

Future<http.Response> COSTS_SET(
    String? token, CostsDto dto, int userID) async {
  final response = await http.post(
    Uri.parse(URL_COSTS_SET),
    headers: HEADERS(token),
    body: jsonEncode(dto.toJson()),
  );

  return response;
}
Future<http.Response> COSTS_EDIT(
    String? token, CostsDto dto, int userID) async {
  final response = await http.post(
    Uri.parse(URL_COSTS_EDIT.replaceAll('{costsId}', dto.id.toString())),
    headers: HEADERS(token),
    body: jsonEncode(dto.toJson()),
  );

  return response;
}

Future<http.Response> COSTS_DELETE(String? token, int costsId) async {
  final response = await http.delete(
      Uri.parse(
          URL_COSTS_DELETE.replaceAll('{costsId}', costsId.toString())),
      headers: HEADERS(token));

  return response;
}

// Fetches one season's financial totals and a page of its costs, per
// GET /api/finance/statistics/seasons. Omit `year` for the current season
// (the season starting Sept 1 of `year`); `page`/`perPage` scope the costs
// list within that season.
Future<http.Response> FINANCE_STATISTICS_SEASONS(String? token,
    {int? year, int page = 1, int perPage = 20}) async {
  final uri = Uri.parse(URL_FINANCE_STATISTICS_SEASONS).replace(
    queryParameters: {
      if (year != null) 'year': year.toString(),
      'page': page.toString(),
      'per_page': perPage.toString(),
    },
  );
  final response = await http.get(uri, headers: HEADERS(token));

  return response;
}
