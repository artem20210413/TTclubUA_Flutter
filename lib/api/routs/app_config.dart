import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../routs.dart';

Future<http.Response> CHECK_APP_CONFIG(String? token) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  String platform = Platform.isAndroid ? 'android' : 'ios';

  final uri = Uri.parse(URL_APP_CONFIG.replaceAll('{platform}', platform));

  return await http.get(uri, headers: {
    ...HEADERS(token),
    'X-App-Version': version, // Передаем версию в заголовке, как просит бэк
  });
}
