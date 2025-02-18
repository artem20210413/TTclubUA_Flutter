import 'package:dio/dio.dart';
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
