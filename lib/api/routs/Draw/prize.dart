import 'dart:io';

import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'package:tt_club_ua/api/routs/Dto/Draw/DrawDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Draw/PrizeDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Finance/FinanceDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Goods/GoodsDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Partners/PartnerDto.dart';
import 'dart:convert';

import 'package:tt_club_ua/api/routs/Dto/User/UserUpdateDto.dart';

import '../../../Storage/Search/ImageUrlDto.dart';

Future<http.Response> DRAW_PRIZE_LIST(String? token, int draw_id) async {
  final uri =
      Uri.parse(URL_DRAWS_PRIZES_LIST.replaceAll('{draw}', draw_id.toString()));
  final response = await http.get(uri, headers: HEADERS(token));

  return response;
}

Future<http.Response> DRAW_PRIZE_CREATE(
    String? token, PrizeDto dto, String? path) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(
        URL_DRAWS_PRIZES_CREATE.replaceAll('{draw}', dto.drawId.toString())),
  );

  if (path != null && path.isNotEmpty && File(path).existsSync()) {
    request.files.add(await http.MultipartFile.fromPath('file', path));
  }

  request.headers['Authorization'] = 'Bearer $token';

  final Map<String, dynamic> data = dto.toJson();
  data.forEach((key, value) {
    if (value != null) {
      request.fields[key] = value.toString();
    }
  });

  var streamedResponse = await request.send();

  return await http.Response.fromStream(streamedResponse);
}

Future<http.Response> DRAW_PRIZE_UPLOAD(
    String? token, PrizeDto dto, String? path) async {
  var request = http.MultipartRequest(
    'PUT',
    Uri.parse(
        URL_DRAWS_PRIZES_UPDATE.replaceAll('{draw}', dto.drawId.toString())),
  );

  if (path != null && path.isNotEmpty && File(path).existsSync()) {
    request.files.add(await http.MultipartFile.fromPath('file', path));
  }

  request.headers['Authorization'] = 'Bearer $token';

  final Map<String, dynamic> data = dto.toJson();
  data.forEach((key, value) {
    if (value != null) {
      request.fields[key] = value.toString();
    }
  });

  var streamedResponse = await request.send();

  return await http.Response.fromStream(streamedResponse);
}

Future<http.Response> DRAW_PRIZE_IMAGE_DELETE(
    String? token, PrizeDto dto) async {
  final url = URL_DRAWS_PRIZES_IMAGE_DELETE
      .replaceAll('{draw}', dto.drawId.toString())
      .replaceAll('{prize}', dto.id.toString());

  final response = await http.delete(
    Uri.parse(url),
    headers: HEADERS(token),
  );

  return response;
}

Future<http.Response> DRAW_PRIZE_IMAGE_ADD(
    String? token, PrizeDto dto, String path) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(URL_DRAWS_PRIZES_IMAGE_ADD
        .replaceAll('{draw}', dto.drawId.toString())
        .replaceAll('{prize}', dto.id.toString())),
  );

  request.files.add(await http.MultipartFile.fromPath('file', path));
  request.headers['Authorization'] = 'Bearer $token';

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  return response;
}

Future<http.Response> DRAW_PRIZE_DELETE(
    String? token, PrizeDto dto, ImageUrlDto img_dto) async {
  final url = URL_DRAWS_PRIZES_IMAGE_DELETE
      .replaceAll('{draw}', dto.drawId.toString())
      .replaceAll('{prize}', dto.id.toString())
      .replaceAll('{mediaId}', img_dto.id.toString());

  final response = await http.delete(
    Uri.parse(url),
    headers: HEADERS(token),
  );

  return response;
}
