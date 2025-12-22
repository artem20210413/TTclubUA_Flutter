import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;

Future API_SYSTEM_USER_STATS(String? token) async {
  final response =
      await http.get(Uri.parse(URL_SYSTEM_USER_STATS), headers: HEADERS(token));

  return response;
}
