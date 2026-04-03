import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'package:tt_club_ua/api/routs/Dto/Finance/FinanceDto.dart';
import 'dart:convert';

import 'package:tt_club_ua/api/routs/Dto/User/UserUpdateDto.dart';

Future<http.Response> FINANCE_SET(
    String? token, FinanceDto dto, int userID) async {
  final response = await http.post(
    Uri.parse(URL_FINANCE_SET.replaceAll('{userId}', userID.toString())),
    headers: HEADERS(token),
    body: jsonEncode(dto.toJson()),
  );

  return response;
}

Future<http.Response> FINANCE_LIST(String? token, int userID,
    {int page = 1}) async {
  final uri =
      Uri.parse(URL_FINANCE_LIST.replaceAll('{userId}', userID.toString()))
          .replace(queryParameters: {
    'page': page.toString(),
  });
  final response = await http.get(uri, headers: HEADERS(token));

  // print('Response status: ${response.statusCode}');
  // print('Response body: ${jsonDecode(response.body)}');

  return response;
}

Future<http.Response> FINANCE_LINK_JAK(int userID) async {
  final uri = Uri.parse(URL_JAK.replaceAll('{userId}', userID.toString()));

  final response = await http.get(uri, headers: HEADERS());

  return response;
}

Future<http.Response> FINANCE_STATISTICS(String? token, int userID) async {
  final response = await http.get(
      Uri.parse(
          URL_FINANCE_STATISTICS.replaceAll('{userId}', userID.toString())),
      headers: HEADERS(token));

  return response;
}

Future<http.Response> FINANCE_CLOSE(String? token, int userID) async {
  final response = await http.get(
      Uri.parse(
          URL_FINANCE_STATISTICS.replaceAll('{userId}', userID.toString())),
      headers: HEADERS(token));

  return response;
}

Future<http.Response> FINANCE_DELETE(String? token, int financeId) async {
  final response = await http.delete(
      Uri.parse(
          URL_FINANCE_DELETE.replaceAll('{financeId}', financeId.toString())),
      headers: HEADERS(token));

  return response;
}
