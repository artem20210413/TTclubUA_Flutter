import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;

Future<http.Response> SEND_SUGGESTIONS(
    String? token, List<XFile> pickedImages, String description) async {
  var request = http.MultipartRequest('POST', Uri.parse(URL_SUGGESTIONS_SEND));
  // print(request.url);
  request.headers['Authorization'] = 'Bearer $token';
  request.headers['Accept'] = 'application/json';
  request.headers['X-Client-Platform'] = buildEnvironment();
  // request.headers['Content-Type'] = 'multipart/form-data';

  request.fields['description'] = description;

  // Добавляем несколько файлов
  for (final image in pickedImages) {
    request.files.add(
      await http.MultipartFile.fromPath(
        'files[]', // важно: массив
        image.path,
      ),
    );
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
String buildEnvironment() {
  if (Platform.isAndroid) {
    return 'android';
  }

  if (Platform.isIOS) {
    return 'ios';
  }

  return 'unknown';
}
