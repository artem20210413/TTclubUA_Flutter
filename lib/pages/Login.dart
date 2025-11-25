import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/api/routs/auth.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../components/TTLoading.dart';
import '../components/buttons/GlowingButton.dart';
import '../components/inputs/CustomInputField.dart';

// import 'package:local_auth/local_auth.dart';
// import 'package:flutter/services.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = true;
  bool _isLoadingSubmit = false;
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTokenAndProceed();
    });
  }

  Future<void> _checkTokenAndProceed() async {
    // await Future.delayed(Duration(seconds: 1));
    bool isValidToken = await UserStorage.checkAndUpdate();

    setState(() {
      _isLoading = false;
    });

    if (!isValidToken) return;

    Navigator.pushReplacementNamed(context, '/nav');

    return;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoadingSubmit = true;
      });
      // Собираем данные
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
        MessageModule(
            context,
            'Невірні дані. Схоже, TT не впізнав свого пілота',
            MessageType.error);
        print('Ошибка авторизации ${response.statusCode}: ${response.body}');
      }
      setState(() {
        _isLoadingSubmit = false;
      });
    }
  }

  final Uri _tgForgotUri = Uri.parse(TG_FORGOT_URI);
  final Uri _signupUri = Uri.parse(SIGNUP_URI);

  Future<void> _open(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      MessageModule(
          context, 'Не вдалось відкрити посилання', MessageType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TTColors.background,
      body: Center(
        child: _isLoading
            ? const TTLoading()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 166,
                        height: 166,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // мягкая внешняя аура / свечение
                            Container(
                              width: 182,
                              height: 182,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    // лёгкий светлый «ореол»
                                    color: Colors.white.withOpacity(0.06),
                                    blurRadius: 26,
                                    spreadRadius: 10,
                                  ),
                                  BoxShadow(
                                    // плотная тень снизу для глубины
                                    color: Colors.black.withOpacity(0.55),
                                    blurRadius: 30,
                                    spreadRadius: -6,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                            ),

                            // тёмный диск с внутренней виньеткой + тонкий кант
                            Container(
                              width: 166,
                              height: 166,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.75),
                                    Colors.black.withOpacity(0.10),
                                    Colors.white.withOpacity(0.2),
                                  ],
                                  // stops: const [0.60, 0.85, 1.00],
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
                              height: 133,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text('Вхід',
                          textAlign: TextAlign.center,
                          style: TTTextStyle.title),
                      const SizedBox(height: 16),
                      CustomInputField(
                        controller: _phoneController,
                        label: 'Номер телефону',
                        prefixText: '+',
                        keyboardType: TextInputType.phone,
                        icon: SvgPicture.asset(
                          'assets/svg/user.svg',
                          fit: BoxFit.none,
                          // игнорировать внешние ограничения на масштаб
                          width: 36,
                          height: 36,
                          // якщо треба перекрасити:
                          colorFilter: ColorFilter.mode(
                              TTColors.text_secondary, BlendMode.srcIn),
                        ),
                        // ),
                        // SvgPicture.asset(
                        //   'assets/svg/user_login.svg',
                        //   width: 36,
                        //   height: 36,
                        //   // якщо треба перекрасити:
                        //   colorFilter: ColorFilter.mode(
                        //       TTColors.text_secondary, BlendMode.srcIn),
                        // ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Введіть номер телефону';
                          if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value))
                            return 'Невірний формат номеру телефону';
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      CustomInputField(
                        controller: _passwordController,
                        label: 'Пароль',
                        obscureText: true,
                        icon: SvgPicture.asset(
                          'assets/svg/lock.svg',
                          width: 36,
                          height: 36,
                          // якщо треба перекрасити:
                          colorFilter: ColorFilter.mode(
                              TTColors.text_secondary, BlendMode.srcIn),
                        ),
                        // icon: Icons.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Введіть пароль';
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
                              : () => _open(_tgForgotUri),
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
                      const SizedBox(height: 80),

                      // Center(
                      //   child: Text(
                      //     'Заявки для вступу подаються на нашому сайті.',
                      //     textAlign: TextAlign.center,
                      //     style: TextStyle(
                      //       color: TTColors.text_secondary,
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.w400,
                      //     ),
                      //   ),
                      // ),


                      // Center(
                      //   child: GestureDetector(
                      //     onTap:
                      //         _isLoadingSubmit ? null : () => _open(_signupUri),
                      //     child: RichText(
                      //       text: TextSpan(
                      //         style: const TextStyle(
                      //             fontFamily: TTTextStyle.fontFamily),
                      //         children: [
                      //           TextSpan(
                      //             text: 'Ще не з нами? ',
                      //             style: TextStyle(
                      //               color: TTColors.text_secondary,
                      //               fontSize: 16,
                      //               fontWeight: FontWeight.w400,
                      //             ),
                      //           ),
                      //           const TextSpan(
                      //             text: 'Зареєструйся!',
                      //             style: TextStyle(
                      //               color: Colors.white,
                      //               fontSize: 17,
                      //               fontWeight: FontWeight.w700,
                      //               decoration: TextDecoration.underline,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
