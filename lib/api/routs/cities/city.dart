import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<http.Response> GET_CITIES(String? token) async {
  final response = await http.get(Uri.parse(URL_CITIES), headers: HEADERS(token));
  // print('Response status: ${response.statusCode}');
  // print('Response body: ${jsonDecode(response.body)}');

  return response;
}
