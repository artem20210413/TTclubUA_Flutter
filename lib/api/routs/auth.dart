import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

Future<void> API_LOGOUT(String? token) async {
  await http.post(
    Uri.parse(URL_LOGOUT),
    headers: HEADERS(token),
  );
}

Future API_AUTH_CHECK(String? token) async {
  print(URL_USER);
  final response = await http.get(Uri.parse(URL_USER), headers: HEADERS(token));
  // return response.statusCode == 200;
  return response;
}
