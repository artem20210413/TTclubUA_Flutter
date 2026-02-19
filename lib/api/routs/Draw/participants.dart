import 'dart:io';

import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'package:tt_club_ua/api/routs/Dto/Draw/DrawDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Draw/ParticipantDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Finance/FinanceDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Goods/GoodsDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Partners/PartnerDto.dart';
import 'dart:convert';

import 'package:tt_club_ua/api/routs/Dto/User/UserUpdateDto.dart';

import '../../../Storage/Search/ImageUrlDto.dart';

Future<http.Response> DRAW_PARTICIPANTS_LIST(String? token, DrawDto dto) async {
  final uri = Uri.parse(
      URL_DRAWS_PARTICIPANTS_LIST.replaceAll('{draw}', dto.id.toString()));
  final response = await http.get(uri, headers: HEADERS(token));

  return response;
}

Future<http.Response> DRAWS_PARTICIPANTS_REGISTER(
    String? token, int draw_id) async {
  final response = await http.post(
    Uri.parse(URL_DRAWS_PARTICIPANTS_REGISTER.replaceAll(
        '{draw}', draw_id.toString())),
    headers: HEADERS(token),
  );

  return response;
}

Future<http.Response> DRAWS_PARTICIPANTS_REGISTER_MANUAL(
    String? token, int draw_id, ParticipantDto dto) async {
  final response = await http.post(
    Uri.parse(URL_DRAWS_PARTICIPANTS_REGISTER_MANUAL.replaceAll(
        '{draw}', draw_id.toString())),
    headers: HEADERS(token),
    body: jsonEncode(dto.toJson()),
  );

  return response;
}

Future<http.Response> DRAWS_PARTICIPANTS_UPDATE(
    String? token, int draw_id, int participant_id, String weight) async {
  final response = await http.post(
    Uri.parse(URL_DRAWS_PARTICIPANTS_UPDATE
        .replaceAll('{draw}', draw_id.toString())
        .replaceAll('{participant}', participant_id.toString())),
    headers: HEADERS(token),
    body: jsonEncode({weight: weight}),
  );

  return response;
}

Future<http.Response> DRAW_IMAGE_DELETE(
    String? token, int draw_id, int participant_id) async {
  final url = URL_DRAWS_PARTICIPANTS_DELETE
      .replaceAll('{draw}', draw_id.toString())
      .replaceAll('{participant}', participant_id.toString());

  final response = await http.delete(
    Uri.parse(url),
    headers: HEADERS(token),
  );

  return response;
}
