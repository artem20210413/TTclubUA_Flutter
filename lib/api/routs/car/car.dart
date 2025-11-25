import 'dart:convert';
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;

import '../Dto/Car/CarDto.dart';

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

Future<Response> GET_COLORS(String? token) async {
  final response = await Dio().get(
    URL_COLOR,
    options: Options(
      headers: HEADERS(token),
    ),
  );

  return response;
}

Future<http.Response> SEARCH_CAR(String? token, String? search,
    {int page = 1}) async {
  final uri = Uri.parse(URL_SEARCH_CAR).replace(queryParameters: {
    'search': search ?? '',
    'page': page.toString(),
  });

  final response = await http.get(uri, headers: HEADERS(token));
  return response;
}

Future<http.Response> CAR_FIND(String? token, int carId) async {
  final response = await http.get(
      Uri.parse(URL_CAR_FIND.replaceAll('{id}', carId.toString())),
      headers: HEADERS(token));

  return response;
}

Future<http.Response> CAR_DELETE(String? token, int carId) async {
  final response = await http.delete(
      Uri.parse(URL_CAR_DELETE.replaceAll('{id}', carId.toString())),
      headers: HEADERS(token));

  return response;
}

Future<http.Response> SEND_MENTION(
    String? token, XFile? pickedImage, String description, String carId) async {
  var request =
      http.MultipartRequest('POST', Uri.parse(URL_MENTION_CAR + carId));
  // print(request.url);
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

Future<http.Response> UPLOAD_CAR_BY_ID(String? token, CarDto car) async {
  // print('URL: ' + URL_CAR_UPDATE.replaceAll('{id}', car.id.toString()));
  // print('User Data: ${car.toJson()}');

  final response = await http.post(
    Uri.parse(URL_CAR_UPDATE.replaceAll('{id}', car.id.toString())),
    headers: HEADERS(token),
    body: jsonEncode(car.toJson()),
  );
  print('Response status: ${response.statusCode}');
  print('Response body: ${jsonDecode(response.body)}');

  return response;
}

Future<http.Response> CREATE_CAR(String? token, CarDto car) async {
  // print('URL: ' + URL_CAR_UPDATE.replaceAll('{id}', car.id.toString()));
  // print('User Data: ${car.toJson()}');

  final response = await http.post(
    Uri.parse(URL_CAR_CREATE),
    headers: HEADERS(token),
    body: jsonEncode(car.toJson()),
  );
  // print('Response status: ${response.statusCode}');
  // print('Response body: ${jsonDecode(response.body)}');

  return response;
}

Future<http.Response> CAR_ADD_COLLECTION(
    String? token, int carId, String path) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(URL_CAR_ADD_COLLECTIONS.replaceAll('{id}', carId.toString())),
  );

  request.files.add(await http.MultipartFile.fromPath('file', path));
  request.headers['Authorization'] = 'Bearer $token';

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  return response;
}

Future<http.Response> CAR_IMAGE_DELETE(String? token, CarDto car) async {
  final response = await http.delete(
    Uri.parse(URL_CAR_DELETE_COLLECTIONS
        .replaceAll('{car}', car.id.toString())
        .replaceAll('{images}', car.imageUrls!.first.id.toString())),
    headers: HEADERS(token),
  );

  return response;
}
