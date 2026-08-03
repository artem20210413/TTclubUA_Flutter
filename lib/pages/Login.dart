import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/api/routs/auth.dart';
import 'package:tt_club_ua/config/default.dart';

import '../components/TTLoading.dart';
import '../components/buttons/GlowingButton.dart';
import '../components/generalModule.dart';
import '../components/inputs/CustomInputField.dart';
import '../utils/url_launcher.dart';
import 'Auth/LoginPhonePasswordScreen.dart';
import 'Auth/LoginTgCodeScreen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = true;
  bool _isSendingCode = false;
  String _phone = '';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final Uri _tgForgotUri = Uri.parse(TG_FORGOT_URI);
  final Uri _signupUri = Uri.parse(SIGNUP_URI);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTokenAndProceed();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _checkTokenAndProceed() async {
    bool isValidToken = await UserStorage.checkAndUpdate();

    setState(() {
      _isLoading = false;
    });

    if (!isValidToken) return;

    Navigator.pushReplacementNamed(context, '/nav');

    return;
  }

  /// The phone fields all show a visual "+" via `prefixText`, so `_phone`
  /// and the controllers must never store a leading "+" themselves —
  /// otherwise it gets prepended a second time visually (e.g. "++380...").
  /// Only the raw string sent to the API needs the "+" added back.
  String _stripPlus(String value) =>
      value.startsWith('+') ? value.substring(1) : value;

  /// Sends the Telegram login code directly from the login screen — no
  /// intermediate "choose a method" step, per product request.
  Future<void> _sendTelegramCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSendingCode = true);

    final raw = _stripPlus(_phoneController.text.trim());
    final phoneWithPlus = '+$raw';

    try {
      final res = await API_LOGIN_TG_SEND_CODE(phoneWithPlus);
      if (res.statusCode == 200) {
        MessageModule(
          context,
          'Код відправлено в Telegram. Перевірте бот.',
          MessageType.success,
        );

        _phone = raw;
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LoginTgCodeScreen(phone: phoneWithPlus),
          ),
        );
        if (result is String && mounted) {
          setState(() => _phone = _stripPlus(result));
        }
      } else if (res.statusCode < 500) {
        final text = json.decode(res.body);
        MessageModule(
          context,
          text['message'] ?? 'упсс..',
          MessageType.error,
        );
      }
      if (res.statusCode == 400) {
        UrlHelper.openExternal(
          context,
          _tgForgotUri,
          title: 'Перехід до Telegram',
          message:
              'Будь ласка, підтвердіть номер телефону через Telegram-бот, перш ніж входити. \nВи збираєтесь відкрити зовнішній застосунок Telegram. Продовжити?',
        );
      }
    } catch (e) {
      MessageModule(
        context,
        'Сталася помилка. Спробуйте пізніше.',
        MessageType.error,
      );
    } finally {
      if (mounted) setState(() => _isSendingCode = false);
    }
  }

  Future<void> _openPhonePasswordLogin() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPhonePasswordScreen(initialPhone: _phone),
      ),
    );
    if (result != null && mounted) {
      final normalized = _stripPlus(result);
      setState(() {
        _phone = normalized;
        _phoneController.text = normalized;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TTColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Center(
          child: _isLoading
              ? const TTLoading()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    // Scale the logo/spacing down on small viewports
                    // (e.g., ~320px width) so nothing overflows.
                    final scale =
                        (constraints.maxWidth / 360).clamp(0.75, 1.0);
                    final logoOuter = 182 * scale;
                    final logoInner = 166 * scale;
                    final logoImageHeight = 133 * scale;

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(32 * scale),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: logoInner,
                              height: logoInner,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // мягкая внешняя аура / свечение
                                  Container(
                                    width: logoOuter,
                                    height: logoOuter,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          // лёгкий светлый «ореол»
                                          color:
                                              Colors.white.withOpacity(0.06),
                                          blurRadius: 26,
                                          spreadRadius: 10,
                                        ),
                                        BoxShadow(
                                          // плотная тень снизу для глубины
                                          color:
                                              Colors.black.withOpacity(0.55),
                                          blurRadius: 30,
                                          spreadRadius: -6,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // тёмный диск с внутренней виньеткой + тонкий кант
                                  Container(
                                    width: logoInner,
                                    height: logoInner,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withOpacity(0.75),
                                          Colors.black.withOpacity(0.10),
                                          Colors.white.withOpacity(0.2),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(
                                        color: Colors.black.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                  ),

                                  // логотип сверху
                                  Image.network(
                                    LOGO_IMAGE_DEFAULT,
                                    fit: BoxFit.contain,
                                    height: logoImageHeight,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 32 * scale),
                            Text('Вхід через Telegram',
                                textAlign: TextAlign.center,
                                style: TTTextStyle.title),
                            const SizedBox(height: 12),
                            Text(
                              'Введіть номер телефону, на який зареєстрований ваш Telegram. Ми надішлемо код входу в бот.',
                              style: TTTextStyle.subtitle,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24 * scale),
                            CustomInputField(
                              controller: _phoneController,
                              label: 'Номер телефону',
                              prefixText: '+',
                              keyboardType: TextInputType.phone,
                              suffixIcon: SvgPicture.asset(
                                'assets/svg/user.svg',
                                fit: BoxFit.none,
                                width: 36,
                                height: 36,
                                colorFilter: ColorFilter.mode(
                                  TTColors.text_secondary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              validator: (_) {
                                final value = _phoneController.text;
                                if (value.trim().isEmpty) {
                                  return 'Введіть номер телефону';
                                }
                                final v = value.replaceAll(' ', '');
                                if (!RegExp(r'^\+?\d{9,12}$').hasMatch(v)) {
                                  return 'Невірний формат номеру телефону';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24 * scale),
                            GlowingButton(
                              text: 'Надіслати код в Telegram',
                              onPressed:
                                  _isSendingCode ? () {} : _sendTelegramCode,
                              isLoading: _isSendingCode,
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed:
                                    _isSendingCode ? null : _openPhonePasswordLogin,
                                style: TextButton.styleFrom(
                                  foregroundColor: TTColors.text_secondary,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                ),
                                child: const Text(
                                  'Увійти за паролем',
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 40 * scale),
                            Center(
                              child: GestureDetector(
                                onTap: () =>
                                    UrlHelper.openExternal(context, _signupUri),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        fontFamily: TTTextStyle.fontFamily),
                                    children: [
                                      TextSpan(
                                        text: 'Ще не з нами? ',
                                        style: TextStyle(
                                          color: TTColors.text_secondary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: 'Заповнюй форму!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
