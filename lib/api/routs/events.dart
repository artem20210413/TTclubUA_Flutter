import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'package:tt_club_ua/api/routs/Dto/Event/EventDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Finance/FinanceDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Goods/GoodsDto.dart';
import 'dart:convert';

import 'package:tt_club_ua/api/routs/Dto/User/UserUpdateDto.dart';

import '../../Storage/Search/ImageUrlDto.dart';

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

Future<http.Response> CALENDAR_LIST(String? token, {int page = 1}) async {
  final uri = Uri.parse(URL_GOODS_LIST).replace(queryParameters: {
    // 'title': title,
    'page': page.toString(),
  });
  final response = await http.get(uri, headers: HEADERS(token));

  // print('Response status: ${response.statusCode}');
  // print('Response body: ${jsonDecode(response.body)}');

  return response;
}

Future<http.Response> EVENT_IMAGE_DELETE(
    String? token, int itemId, ImageUrlDto dto) async {
  final url = URL_EVENT_DELETE_IMAGE
      .replaceAll('{event}', itemId.toString())
      .replaceAll('{mediaId}', dto.id.toString());

  final response = await http.delete(
    Uri.parse(url),
    headers: HEADERS(token),
  );

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
