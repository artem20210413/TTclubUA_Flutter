import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;

const _kRequestTimeout = Duration(seconds: 15);

Future<http.Response> GET_MENTION_LOCATIONS(String? token) async {
  final response = await http
      .get(Uri.parse(URL_MENTION_LOCATIONS), headers: HEADERS(token))
      .timeout(_kRequestTimeout);

  return response;
}
