import 'package:dio/dio.dart';
import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Storage/Auth/ChangePasswordDto.dart';

// Map<String, String> _headers([String? token = null]) {
//   return {
//     'Content-Type': 'application/json; charset=UTF-8',
//     'Accept': 'application/json; charset=UTF-8',
//     if (token != null) 'Authorization': 'Bearer $token',
//   };
// }
// Map<String, String> HEADERS([String? token = null]) {
//   return {
//     'Content-Type': 'application/json; charset=UTF-8',
//     'Accept': 'application/json; charset=UTF-8',
//     if (token != null) 'Authorization': 'Bearer $token',
//   };
// }

Future API_LOGIN(String login, String password) async {
  final response = await http.post(
    Uri.parse(URL_LOGIN),
    headers: HEADERS(),
    body: jsonEncode(<String, String>{
      'login': login,
      'password': password,
    }),
  );

  return response;
}

Future API_LOGIN_TG_VERIFY(String phone, String code) async {
  final response = await http.post(
    Uri.parse(URL_LOGIN_TG_VERIFY),
    headers: HEADERS(),
    body: jsonEncode(<String, String>{
      'phone': phone,
      'code': code,
    }),
  );

  return response;
}

Future API_LOGIN_TG_SEND_CODE(String phone) async {
  final response = await http.post(
    Uri.parse(URL_LOGIN_TG_SEND_CODE),
    headers: HEADERS(),
    body: jsonEncode(<String, String>{
      'phone': phone,
    }),
  );

  return response;
}

Future<void> API_LOGOUT(String? token) async {
  await http.post(
    Uri.parse(URL_LOGOUT),
    headers: HEADERS(token),
  );
}

Future API_AUTH_CHECK(String? token) async {
  // print(URL_USER);
  final response = await http.get(Uri.parse(URL_USER), headers: HEADERS(token));
  // return response.statusCode == 200;
  return response;
}

Future<http.Response> API_CHANGE_PASSWORD(
    String? token, ChangePasswordDto dto) async {
  final response = await http.post(
    Uri.parse(URL_CHANGE_PASSWORD),
    headers: HEADERS(token),
    body: jsonEncode(dto.toJson()),
  );
  // print(jsonDecode(response.body));

  return response;
}

Future<http.Response> API_DELETE_ACCOUNT(String? token) async {
  final response = await http.delete(
    Uri.parse(URL_DELETE_ACCOUNT),
    headers: HEADERS(token),
  );

  return response;
}
