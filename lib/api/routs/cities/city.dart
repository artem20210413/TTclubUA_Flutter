import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<http.Response> GET_CITIES(String? token) async {
  final response = await http.get(Uri.parse(URL_CITIES), headers: HEADERS(token));
  // print('Response status: ${response.statusCode}');
  // print('Response body: ${jsonDecode(response.body)}');

  return response;
}

Future<http.Response> GET_CITIES_MAP(String? token) async {
  final response =
      await http.get(Uri.parse(URL_CITIES_MAP), headers: HEADERS(token));

  return response;
}

Future<http.Response> GET_CITY_USERS(String? token, int cityId,
    {int page = 1}) async {
  final uri = Uri.parse(URL_CITIES_USERS.replaceAll('{id}', cityId.toString()))
      .replace(queryParameters: {'page': page.toString()});

  final response = await http.get(uri, headers: HEADERS(token));

  return response;
}
