import 'dart:convert';

import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;

Future API_FCM_TOKEN_SEND(String? token, String fcmToken) async {
  final response = await http.post(
    Uri.parse(URL_FCM_TOKEN),
    headers: HEADERS(token),
    body: jsonEncode(<String, String>{
      'token': fcmToken,
    }),
  );

  return response;
}

Future API_FCM_TOGGLE(String? token, String fcmToken, int active) async {
  final response = await http.patch(
    Uri.parse(URL_FCM_TOGGLE),
    headers: HEADERS(token),
    body: jsonEncode(<String, String>{
      'token': fcmToken,
      'active': active.toString(),
    }),
  );

  return response;
}
