import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tt_club_ua/api/routs/auth.dart';
import 'package:tt_club_ua/components/TTLoading.dart';
import 'package:tt_club_ua/components/buttons/GlowingButton.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/components/inputs/CustomInputField.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../components/layout/TTScaffold.dart';
import '../../utils/url_launcher.dart';
import 'LoginTgCodeScreen.dart';

class LoginTgPhoneScreen extends StatefulWidget {
  final String? initialPhone;

  const LoginTgPhoneScreen({super.key, this.initialPhone});

  @override
  State<LoginTgPhoneScreen> createState() => _LoginTgPhoneScreenState();
}

class _LoginTgPhoneScreenState extends State<LoginTgPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final Uri _tgForgotUri = Uri.parse(TG_FORGOT_URI);

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.initialPhone ?? "";
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String raw = _phoneController.text.trim();
    final phone = raw.startsWith('+') ? raw : '+$raw';

    try {
      final res = await API_LOGIN_TG_SEND_CODE(phone);
      print('--------');
      print(res.statusCode);
      if (res.statusCode == 200) {
        MessageModule(
          context,
          'Код відправлено в Telegram. Перевірте бот.',
          MessageType.success,
        );

        /// 🔥 Переходим на вторую страницу, передаём номер
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LoginTgCodeScreen(phone: phone),
          ),
        );
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Вхід через Telegram',
      body: Center(
        child: _isLoading
            ? const TTLoading()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Заголовок
                      // Text(
                      //   'Вхід через Telegram',
                      //   style: TTTextStyle.title.copyWith(fontSize: 28),
                      //   textAlign: TextAlign.center,
                      // ),

                      const SizedBox(height: 16),

                      /// Подзаголовок
                      Text(
                        'Введіть номер телефону, на який зареєстрований ваш Telegram. Ми надішлемо код входу в бот.',
                        style: TTTextStyle.subtitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      /// Поле ввода номера
                      CustomInputField(
                        controller: _phoneController,
                        label: 'Номер телефону',
                        prefixText: '+',
                        keyboardType: TextInputType.phone,
                        icon: SvgPicture.asset(
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

                      const SizedBox(height: 32),

                      GlowingButton(
                        text: 'Надіслати код в Telegram',
                        onPressed: _isLoading ? () {} : _sendCode,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 32),

                      /// ✨ Дополнительный информационный текст
                      Center(
                        child: Text(
                          'Вперше? Надішліть свій номер у Telegram-бот.',
                          textAlign: TextAlign.center,
                          style: TTTextStyle.subtitle,
                        ),
                      ),

                      Center(
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => UrlHelper.openExternal(
                                    context,
                                    _tgForgotUri,
                                    title: 'Перехід до Telegram',
                                    message:
                                        'Ви збираєтесь відкрити зовнішній застосунок Telegram. Продовжити?',
                                  ),
                          style: TextButton.styleFrom(
                            foregroundColor: TTColors.text_secondary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                          ),
                          child: Text(
                            'Перейти до бота',
                            style: TTTextStyle.subtitle.copyWith(
                              color: TTColors.text,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
