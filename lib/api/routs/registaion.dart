import 'package:tt_club_ua/Storage/UserDto.dart';
import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tt_club_ua/api/routs/Dto/User/UserUpdateDto.dart';


//URL_USER_FIND.replaceAll('{id}', userId.toString())
Future<http.Response> REGISTRATION_LIST(String? token) async {
  final response = await http.get(
      Uri.parse(URL_REGISTATION_LIST),
      headers: HEADERS(token));

  return response;
}

Future<http.Response> REJECT_REGISTRATION(int id, String? token) async {
  final response = await http.post(
      Uri.parse(URL_REGISTATION_CHANHE_ACTIVE.replaceAll('{id}', id.toString())),
      headers: HEADERS(token));

  return response;
}

Future<http.Response> APPROVE_REGISTRATION(int id, String? token) async {
  final response = await http.post(
      Uri.parse(URL_REGISTATION_APPROVE.replaceAll('{id}', id.toString())),
      headers: HEADERS(token));

  return response;
}
