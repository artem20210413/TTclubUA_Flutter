import 'dart:io';

import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'package:tt_club_ua/api/routs/Dto/Draw/DrawDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Finance/FinanceDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Goods/GoodsDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Partners/PartnerDto.dart';
import 'dart:convert';

import 'package:tt_club_ua/api/routs/Dto/User/UserUpdateDto.dart';

import '../../../Storage/Search/ImageUrlDto.dart';

Future<http.Response> DRAW_LIST(String? token, {int page = 1}) async {
  final uri = Uri.parse(URL_DRAWS_LIST)
      .replace(queryParameters: {'page': page.toString()});
  final response = await http.get(uri, headers: HEADERS(token));

  return response;
}

Future<http.Response> DRAW_SHOW(String? token, int id) async {
  final uri = Uri.parse(URL_DRAWS_SHOW.replaceAll('{draw}', id.toString()));
  final response = await http.get(uri, headers: HEADERS(token));

  return response;
}

Future<http.Response> DRAW_ROLL(
    String? token, int draw_id, int prize_id) async {
  final response = await http.post(
    Uri.parse(URL_DRAWS_ROLL
        .replaceAll('{draw}', draw_id.toString())
        .replaceAll('{prize}', prize_id.toString())),
    headers: HEADERS(token),
  );

  return response;
}

Future<http.Response> DRAW_RESET(
    String? token, int draw_id, int prize_id) async {
  final response = await http.post(
    Uri.parse(URL_DRAWS_RESET
        .replaceAll('{draw}', draw_id.toString())
        .replaceAll('{prize}', prize_id.toString())),
    headers: HEADERS(token),
  );

  return response;
}

Future<http.Response> DRAW_CREATE(
    String? token, DrawDto dto, String? path) async {
  final response = await http.post(
    Uri.parse(URL_DRAWS_CREATE),
    headers: HEADERS(token),
    body: jsonEncode(dto.toJson()),
  );

  return response;
}

Future<http.Response> DRAW_DELETE(String? token, DrawDto dto) async {
  final response = await http.delete(
    Uri.parse(URL_DRAWS_DELETE.replaceAll('{draw}', dto.id.toString())),
    headers: HEADERS(token),
  );

  return response;
}

Future<http.Response> DRAW_UPLOAD(
    String? token, DrawDto dto, String? path) async {
  final response = await http.put(
    Uri.parse(URL_DRAWS_UPDATE.replaceAll('{draw}', dto.id.toString())),
    headers: HEADERS(token),
    body: jsonEncode(dto.toJson()),
  );
  print(jsonEncode(dto.toJson()));

  return response;
}

Future<http.Response> DRAW_IMAGE_ADD(
    String? token, int drawId, String path) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(URL_DRAWS_IMAGE_ADD.replaceAll('{draw}', drawId.toString())),
  );

  request.files.add(await http.MultipartFile.fromPath('file', path));
  request.headers['Authorization'] = 'Bearer $token';

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  return response;
}

Future<http.Response> DRAW_IMAGE_DELETE(
    String? token, int itemId, ImageUrlDto img_dto) async {
  final url = URL_DRAWS_IMAGE_DELETE
      .replaceAll('{draw}', itemId.toString())
      .replaceAll('{mediaId}', img_dto.id.toString());

  final response = await http.delete(
    Uri.parse(url),
    headers: HEADERS(token),
  );

  return response;
}
