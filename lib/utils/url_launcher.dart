import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

import '../components/viewers/ConfirmAndRun.dart';

class UrlHelper {
  /// Открытие ссылки внутри приложения (SafariViewController / WebView)
  static Future<void> openInternal(Uri uri) async {
    final ok = await launchUrl(
      uri,
      mode: LaunchMode.inAppWebView,
    );

    if (!ok) {
      debugPrint('Could not launch $uri');
    }
  }

  /// Открытие ссылки через внешнее приложение (браузер, Telegram и т.д.)
  // static Future<void> openExternal(Uri uri) async {
  //   final ok = await launchUrl(
  //     uri,
  //     mode: LaunchMode.externalApplication,
  //   );
  //
  //   if (!ok) {
  //     debugPrint('Could not launch $uri');
  //   }
  // }

  static Future<void> openExternal(
      BuildContext context,
      Uri uri, {
        String title = 'Відкрити стороннє посилання?',
        String message =
        'Ця дія відкриє стороннє застосування або вебсторінку. Продовжити?',
      }) async {
    ConfirmAndRun(
      context: context,
      dialogTitle: title,
      dialogMessage: message,
      action: () async {
        final ok = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не вдалося відкрити посилання'),
            ),
          );
        }
      },
    );
  }
}
