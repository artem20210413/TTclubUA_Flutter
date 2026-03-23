import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../components/generalModule.dart';

Future<bool> CHECK_API(http.Response res, BuildContext context,
    {bool isEx = true}) async {
  if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
    return true;
  }
  if (isEx) {
    final responseBody = jsonDecode(res.body);
    MessageModule(
        context,
        'Error: ${res.statusCode}. Response body: $responseBody',
        MessageType.error);
  }

  return false;
}
