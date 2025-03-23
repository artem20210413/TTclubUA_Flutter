import 'dart:convert';
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;

Future<Response> GET_MODELS(String? token) async {
  final response = await Dio().get(
    URL_MODELS,
    options: Options(
      headers: HEADERS(token),
    ),
  );
  return response;
}

Future<Response> GET_GENES(String? token) async {
  final response = await Dio().get(
    URL_GENES,
    options: Options(
      headers: HEADERS(token),
    ),
  );

  return response;
}

Future<http.Response> SEARCH_CAR(String? token, String search) async {
  final response = await http.get(Uri.parse(URL_SEARCH_CAR + search),
      headers: HEADERS(token));
  // print('Response status: ${response.statusCode}');
  // print('Response body: ${jsonDecode(response.body)}');

  return response;
}

Future<http.Response> SEND_MENTION(
    String? token, XFile? pickedImage, String description, String carId) async {
  var request =
      http.MultipartRequest('POST', Uri.parse(URL_MENTION_CAR + carId));
  print(request.url);
  request.headers['Authorization'] = 'Bearer $token';
  request.headers['Accept'] = 'application/json';
  request.headers['Content-Type'] = 'multipart/form-data';

  request.fields['description'] = description;
  if (pickedImage != null) {
    request.files
        .add(await http.MultipartFile.fromPath('file', pickedImage.path));
  }

  // Отправляем multipart-запрос
  var streamedResponse = await request.send();

  // Читаем поток и конвертируем в обычный Response
  final responseBody = await streamedResponse.stream.bytesToString();

  final res = http.Response(
    responseBody,
    streamedResponse.statusCode,
    headers: streamedResponse.headers,
    request: streamedResponse.request,
    isRedirect: streamedResponse.isRedirect,
    reasonPhrase: streamedResponse.reasonPhrase,
  );

  // print('Response status: ${res.statusCode}');
  // print('Response body: ${jsonDecode(res.body)}');

  return res;
}
