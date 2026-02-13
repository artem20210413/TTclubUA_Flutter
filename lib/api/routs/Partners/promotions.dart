import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'package:tt_club_ua/api/routs/Dto/Finance/FinanceDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Goods/GoodsDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Partners/PartnerDto.dart';
import 'dart:convert';

import 'package:tt_club_ua/api/routs/Dto/User/UserUpdateDto.dart';

import '../../../Storage/Search/ImageUrlDto.dart';
import '../Dto/Partners/PromotionDto.dart';

Future<http.Response> PARTNERS_PROMOTIONS_LIST(
  String? token,
  PartnerDto dto,{
  String? search,
  int page = 1,
  bool? onlyActive = null,
  bool? activeNow = null,
}) async {
  final uri = Uri.parse(URL_PARTNERS_PROMOTIONS_LIST.replaceAll(
      '{partner}', dto.id.toString())).replace(queryParameters: {
    'page': page.toString(),
    if (onlyActive != null) 'is_active': onlyActive ? '1' : '0',
    if (activeNow != null) 'active_now': activeNow ? '1' : '0',
    if (search != null) 'search': search
  });
  final response = await http.get(uri, headers: HEADERS(token));

  // print('uri: ${uri}');
  // print('Response status: ${response.statusCode}');
  // print('Response body: ${jsonDecode(response.body)}');

  return response;
}

Future<http.Response> PARTNERS_PROMOTIONS_CREATE(
    String? token, PromotionDto dto) async {
  final response = await http.post(
    Uri.parse(URL_PARTNERS_PROMOTIONS_CREATE
        .replaceAll('{partner}', dto.partnerId.toString())),
    headers: HEADERS(token),
    body: jsonEncode(dto.toJson()),
  );

  return response;
}

Future<http.Response> partners_promotions_destroy(
    String? token, PromotionDto dto) async {
  final response = await http.delete(
    Uri.parse(URL_PARTNERS_PROMOTIONS_DESTROY
        .replaceAll('{partner}', dto.partnerId.toString())
        .replaceAll('{promotion}', dto.id.toString())
    ),
    headers: HEADERS(token)
  );

  return response;
}

Future<http.Response> PARTNERS_PROMOTIONS_UPLOAD(
    String? token, PromotionDto dto) async {
  final response = await http.post(
    Uri.parse(URL_PARTNERS_PROMOTIONS_UPDATE
        .replaceAll('{partner}', dto.partnerId.toString())
        .replaceAll('{promotion}', dto.id.toString())
    ),
    headers: HEADERS(token),
    body: jsonEncode(dto.toJson()),
  );

  return response;
}

Future<http.Response> PARTNERS_PROMOTIONS_IMAGE_ADD(
    String? token, int itemId, String path) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(URL_PARTNERS_PROMOTIONS_IMAGE_CREATE.replaceAll(
        '{promotion}', itemId.toString())),
  );

  request.files.add(await http.MultipartFile.fromPath('file', path));
  request.headers['Authorization'] = 'Bearer $token';

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  return response;
}

Future<http.Response> PARTNERS_PROMOTIONS_IMAGE_DELETE(
    String? token, int itemId, ImageUrlDto dto) async {
  final url = URL_PARTNERS_PROMOTIONS_IMAGE_DELETE
      .replaceAll('{promotion}', itemId.toString())
      .replaceAll('{mediaId}', dto.id.toString());

  final response = await http.delete(
    Uri.parse(url),
    headers: HEADERS(token),
  );

  return response;
}
