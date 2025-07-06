import 'package:tt_club_ua/Storage/UserDto.dart';
import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tt_club_ua/api/routs/Dto/User/UserUpdateDto.dart';

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

Future<http.Response> SEARCH_USER_OLD(String? token, String search) async {
  final response = await http.get(Uri.parse(URL_SEARCH_USER_OLD + search),
      headers: HEADERS(token));
  // print('Response status: ${response.statusCode}');
  // print('Response body: ${jsonDecode(response.body)}');

  return response;
}

Future<http.Response> SEARCH_USER(String? token, String search,
    {int page = 1}) async {
  final uri = Uri.parse(URL_SEARCH_USER).replace(queryParameters: {
    'search': search ?? '',
    'page': page.toString(),
  });

  final response = await http.get(uri, headers: HEADERS(token));

  return response;
}

Future<http.Response> USER_FIND(String? token, int userId) async {
  final response = await http.get(
      Uri.parse(URL_USER_FIND.replaceAll('{id}', userId.toString())),
      headers: HEADERS(token));

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

Future<http.Response> UPLOAD_USER_PHOTO_BY_ID(
    String? token, int userId, String path) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(URL_USER_PICTURE_BY_ID.replaceAll('{id}', userId.toString())),
  );

  request.files.add(await http.MultipartFile.fromPath('profile_image', path));
  request.headers['Authorization'] = 'Bearer $token';

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  return response;
}

Future<http.Response> CHANGE_ACTIVE_USER(String? token, int userId) async {
  final response = await http.post(
      Uri.parse(URL_USER_CHANGE_ACTIVE.replaceAll('{id}', userId.toString())),
      headers: HEADERS(token));
  // print('Response status: ${response.statusCode}');
  // print('Response body: ${jsonDecode(response.body)}');

  return response;
}

Future<http.Response> UPLOAD_USER_BY_ID(
    String? token, UserUpdateDto user) async {
  print('URL: ' + URL_USER_UPDATE_BY_ID.replaceAll('{id}', user.id.toString()));
  print('User Data: ${user.toJson()}');

  final response = await http.post(
    Uri.parse(URL_USER_UPDATE_BY_ID.replaceAll('{id}', user.id.toString())),
    headers: HEADERS(token),
    body: jsonEncode(user.toJson()),
  );
  print('Response status: ${response.statusCode}');
  print('Response body: ${jsonDecode(response.body)}');

  return response;
}

Future<http.Response> USER_CHANGE_PASSWARD(
    String? token, int userId, String password) async {
  final response = await http.post(
    Uri.parse(URL_USER_CHANGE_PASSWORD.replaceAll('{id}', userId.toString())),
    headers: HEADERS(token),
    body: jsonEncode({
      'new_password': password,
      'new_password_confirmation': password,
    }),
  );

  return response;
}
