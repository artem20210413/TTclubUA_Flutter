import 'package:tt_club_ua/Storage/UserDto.dart';
import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<http.Response> UPLOAD_USER(String? token, UserDTO user) async {
  // print('URL: $URL_USER');
  // print('User Data: ${user.toJson()}');

  final response = await http.post(
    Uri.parse(URL_USER),
    headers: HEADERS(token),
    body: jsonEncode(user.toJson()),
  );
//   print('Response status: ${response.statusCode}');
//   print('Response body: ${jsonDecode(response.body)}');

  return response;
}
