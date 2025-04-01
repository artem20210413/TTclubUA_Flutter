import 'package:tt_club_ua/Storage/UserDto.dart';
import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<http.Response> HOMEPAGE_DATA(String? token) async {

  final response =
      await http.get(Uri.parse(URL_HOMEPAGE_DATA), headers: HEADERS(token));
  print('Response status: ${response.statusCode}');
  print('Response body: ${jsonDecode(response.body)}');

  return response;
}
