import 'package:tt_club_ua/api/routs.dart';
import 'package:http/http.dart' as http;
import 'package:tt_club_ua/api/routs/Dto/Event/EventDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Finance/FinanceDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Goods/GoodsDto.dart';
import 'dart:convert';

import 'Dto/ExternalCars/ExternalCarFilter.dart';

Future<http.Response> EXTERNAL_CARS_LIST(
  String? token, {
  int page = 1,
  ExternalCarFilterDto? filter,
}) async {
  Map<String, String> queryParams = {
    'page': page.toString(),
  };

  if (filter != null) {
    queryParams.addAll(filter.toQueryParameters());
  }

  final uri = Uri.parse(URL_EXTERNAL_CARS_LIST).replace(
    queryParameters: queryParams,
  );

  // Виконуємо запит
  final response = await http.get(uri, headers: HEADERS(token));

  // print('Request URL: $uri');

  return response;
}

Future<http.Response> EXTERNAL_CARS_FILTER(String? token) async {
  final uri = Uri.parse(URL_EXTERNAL_CARS_FILTERS);
  final response = await http.get(uri, headers: HEADERS(token));

  return response;
}
