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

  return response;
}

Future<http.Response> SEARCH_USER(String? token, String search) async {
  final response = await http.get(Uri.parse(URL_SEARCH_USER + search),
      headers: HEADERS(token));
  // print('Response status: ${response.statusCode}');
  // print('Response body: ${jsonDecode(response.body)}');

  return response;
}

Future<http.Response> UPLOAD_USER_PHOTO(String? token, String path) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(URL_USER_PICTURE),
  );

  request.files.add(await http.MultipartFile.fromPath('profile_image', path));
  request.headers['Authorization'] = 'Bearer $token';

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  return response;
}
