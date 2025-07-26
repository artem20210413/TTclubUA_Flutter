import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'package:tt_club_ua/api/routs/Dto/Costs/CostsDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Finance/FinanceDto.dart';
import 'dart:convert';

import 'package:tt_club_ua/api/routs/Dto/User/UserUpdateDto.dart';

Future<http.Response> COSTS_SET(
    String? token, CostsDto dto, int userID) async {
  final response = await http.post(
    Uri.parse(URL_FINANCE_SET.replaceAll('{userId}', userID.toString())),
    headers: HEADERS(token),
    body: jsonEncode(dto.toJson()),
  );

  return response;
}

Future<http.Response> COSTS_LIST(String? token, {int page = 1}) async {
  final uri =
      Uri.parse(URL_COSTS_LIST)
          .replace(queryParameters: {
    'page': page.toString(),
  });
  print('--------------');
  print(uri);
  final response = await http.get(uri, headers: HEADERS(token));

  // print('Response status: ${response.statusCode}');
  // print('Response body: ${jsonDecode(response.body)}');

  return response;
}

Future<http.Response> COSTS_DELETE(String? token, int costsId) async {
  final response = await http.delete(
      Uri.parse(
          URL_COSTS_DELETE.replaceAll('{costsId}', costsId.toString())),
      headers: HEADERS(token));

  return response;
}
