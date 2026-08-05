import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../Storage/UserStorage.dart';
import '../api/routs/auth.dart';
import '../components/generalModule.dart';

/// Handles the login link a user taps from the "Підтвердити вхід" button in
/// the Telegram bot message. Two forms point here:
/// - Universal/App Link: `https://ttclub.com.ua/auth/tg-code?phone=...&code=...`
/// - Custom-scheme fallback used by that web page when the https link isn't
///   verified yet (e.g. debug builds): `ttclubua://login-tg-code?phone=...&code=...`
///
/// The link never bypasses the normal verify flow — it just triggers the
/// same [API_LOGIN_TG_VERIFY] call the manual code-entry screen makes, so
/// the code still has to be valid/unexpired server-side.
class DeepLinkService {
  static const _httpsHost = 'ttclub.com.ua';
  static const _httpsPath = '/auth/tg-code';
  static const _customScheme = 'ttclubua';
  static const _customSchemeHost = 'login-tg-code';

  final GlobalKey<NavigatorState> navigatorKey;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  DeepLinkService({required this.navigatorKey});

  Future<void> initialize() async {
    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {},
    );

    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      await _handleUri(initialUri);
    }
  }

  void dispose() {
    _subscription?.cancel();
  }

  bool _isLoginTgCodeLink(Uri uri) {
    final isHttpsAppLink = uri.scheme == 'https' &&
        uri.host == _httpsHost &&
        uri.path == _httpsPath;
    final isCustomScheme =
        uri.scheme == _customScheme && uri.host == _customSchemeHost;
    return isHttpsAppLink || isCustomScheme;
  }

  Future<void> _handleUri(Uri uri) async {
    if (!_isLoginTgCodeLink(uri)) return;

    final phone = uri.queryParameters['phone'];
    final code = uri.queryParameters['code'];
    if (phone == null || phone.isEmpty || code == null || code.isEmpty) {
      return;
    }

    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Already logged in — the link is stale/irrelevant, don't touch the
    // current session.
    final isAuthorized = await UserStorage.checkAndUpdate();
    if (isAuthorized) return;

    try {
      final res = await API_LOGIN_TG_VERIFY(phone, code);
      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        await UserStorage.saveToken(jsonData['data']['token']);
        await UserStorage.saveUserInfo(jsonData['data']['user']);

        navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/nav', (route) => false);
      } else {
        if (navigatorKey.currentContext != null) {
          MessageModule(
            navigatorKey.currentContext!,
            'Посилання для входу вже недійсне. Спробуйте ще раз.',
            MessageType.error,
          );
        }
      }
    } catch (_) {
      if (navigatorKey.currentContext != null) {
        MessageModule(
          navigatorKey.currentContext!,
          'Сталася помилка під час входу за посиланням.',
          MessageType.error,
        );
      }
    }
  }
}
