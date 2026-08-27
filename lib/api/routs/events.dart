import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'package:tt_club_ua/api/routs/Dto/Event/EventDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Finance/FinanceDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Goods/GoodsDto.dart';
import 'dart:convert';

import 'package:tt_club_ua/api/routs/Dto/User/UserUpdateDto.dart';

import '../../Storage/Search/ImageUrlDto.dart';

Future<http.Response> EVENT_SHOW(String? token, int id) async {
  final uri = Uri.parse(URL_EVENT_UPLOAD.replaceAll('{event}', id.toString()));
  final response = await http.get(uri, headers: HEADERS(token));

  return response;
}

Future<http.Response> EDENT_UPLOAD(String? token, EventDto dto) async {
  final response = await http.put(
    Uri.parse(URL_EVENT_UPLOAD.replaceAll('{event}', dto.id.toString())),
    headers: HEADERS(token),
    body: jsonEncode(dto.toJson()),
  );

  return response;
}

Future<http.Response> EDENT_CREATE(String? token, EventDto dto) async {
  final response = await http.post(
    Uri.parse(URL_EVENT_CREATE),
    headers: HEADERS(token),
    body: jsonEncode(dto.toJson()),
  );

  return response;
}

Future<http.Response> CALENDAR_LIST(String? token,
    {String? month = null, int page = 1}) async {
  final uri = Uri.parse(URL_CALENDAR_LIST).replace(queryParameters: {
    // 'title': title,
    'month': month, // формат YYYY-MM
    'page': page.toString(),
  });

  final response = await http.get(uri, headers: HEADERS(token));

  // print('Response status: ${response.statusCode}');
  // print('Response body: ${jsonDecode(response.body)}');

  return response;
}

Future<http.Response> CALENDAR_DESCRIPTION(String? token, String event) async {
  final uri = Uri.parse(URL_CALENDAR_DESCRIPTION.replaceAll('{event}', event));
  final response = await http.get(uri, headers: HEADERS(token));

  return response;
}

Future<http.Response> EVENT_LIST(
  String? token,
  String search, {
  int page = 1,
  int? type, // наприклад: "club", "world", "birthday"
  bool? active, // якщо потрібно
}) async {
  final query = <String, String>{
    'page': page.toString(),
  };

  if (search.trim().isNotEmpty) {
    query['search'] = search.trim();
  }
  if (type != null && type != 0) {
    query['type'] = type.toString();
  }
  if (active != null) {
    query['active'] = active ? '1' : '0';
  }
  print(URL_EVENT_LIST);
  print(query);
  final uri = Uri.parse(URL_EVENT_LIST).replace(queryParameters: query);

  final response = await http.get(
    uri,
    headers: HEADERS(token),
  );

  return response;
}

Future<http.Response> EVENT_TYPE_LIST(String? token) async {
  final uri = Uri.parse(URL_EVENT_TYPE_LIST);

  final response = await http.get(
    uri,
    headers: HEADERS(token),
  );

  return response;
}

Future<http.Response> EVENT_IMAGE_DELETE(
    String? token, int itemId, ImageUrlDto dto) async {
  final url = URL_EVENT_COLLECTIONS_IMAGE
      .replaceAll('{event}', itemId.toString())
      .replaceAll('{mediaId}', dto.id.toString());
// print(url);
  final response = await http.delete(
    Uri.parse(url),
    headers: HEADERS(token),
  );
  // print(response.body);

  return response;
} //

Future<http.Response> EVENT_IMAGE_ADD(
    String? token, int itemId, String path) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(URL_EVENT_ADD_IMAGE.replaceAll('{event}', itemId.toString())),
  );

  request.files.add(await http.MultipartFile.fromPath('file', path));
  request.headers['Authorization'] = 'Bearer $token';

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  return response;
}
