import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/api/routs/auth.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../components/buttons/GlowingButton.dart';
import '../../components/inputs/CustomInputField.dart';
import '../../utils/url_launcher.dart';

class LoginPhonePasswordScreen extends StatefulWidget {
  final String? initialPhone;

  const LoginPhonePasswordScreen({super.key, this.initialPhone});

  @override
  State<LoginPhonePasswordScreen> createState() =>
      _LoginPhonePasswordScreenState();
}

class _LoginPhonePasswordScreenState extends State<LoginPhonePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final Uri _tgForgotUri = Uri.parse(TG_FORGOT_URI);

  bool _isLoadingSubmit = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.initialPhone ?? '';
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoadingSubmit = true;
    });

    final phone = _phoneController.text;
    final password = _passwordController.text;
    final response = await API_LOGIN(phone, password);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      MessageModule(context, 'TT впізнав свого пілота. Заїжджай до гаража',
          MessageType.success);

      await UserStorage.saveToken(responseData['data']['token']);
      await UserStorage.saveUserInfo(responseData['data']['user']);
      Navigator.pushReplacementNamed(context, '/nav');
    } else if (response.statusCode == 500) {
      MessageModule(
          context,
          'Упсс... сервер не на зв’язку. Спробуйте трохи згодом',
          MessageType.error);
    } else {
      MessageModule(context, 'Невірні дані. Схоже, TT не впізнав свого пілота',
          MessageType.error);
      print('Ошибка авторизации ${response.statusCode}: ${response.body}');
    }

    if (mounted) {
      setState(() {
        _isLoadingSubmit = false;
      });
    }
  }

  void _popWithPhone([bool result = true]) {
    Navigator.pop(context, _phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _popWithPhone();
      },
      child: Scaffold(
        backgroundColor: TTColors.background,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 32,
          centerTitle: true,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: _popWithPhone,
          ),
          title: Text('Вхід за телефоном', style: TTTextStyle.title18),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Введіть номер телефону та пароль від вашого акаунту',
                        textAlign: TextAlign.center,
                        style: TTTextStyle.subtitle,
                      ),
                      const SizedBox(height: 24),
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
                              TTColors.text_secondary, BlendMode.srcIn),
                        ),
                        validator: (_) {
                          final value = _phoneController.text;
                          if (value.isEmpty) return 'Введіть номер телефону';
                          if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) {
                            return 'Невірний формат номеру телефону';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomInputField(
                        controller: _passwordController,
                        label: 'Пароль',
                        obscureText: true,
                        suffixIcon: SvgPicture.asset(
                          'assets/svg/lock.svg',
                          width: 36,
                          height: 36,
                          colorFilter: ColorFilter.mode(
                              TTColors.text_secondary, BlendMode.srcIn),
                        ),
                        validator: (_) {
                          final value = _passwordController.text;
                          if (value.isEmpty) return 'Введіть пароль';
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      GlowingButton(
                        text: 'Увійти',
                        onPressed: () {
                          _submitForm();
                        },
                        isLoading: _isLoadingSubmit,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: _isLoadingSubmit
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
                          child: const Text(
                            'Забули пароль?',
                            style: TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
