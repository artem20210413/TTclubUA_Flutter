import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/api/routs/auth.dart';
import 'package:tt_club_ua/config/default.dart';
import 'dart:convert';

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
      // Собираем данные
      final phone = _phoneController.text;
      final password = _passwordController.text;
      final response = await API_LOGIN(phone, password);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        MessageModule(context, 'Авторизация успешна', MessageType.success);

        await UserStorage.saveToken(responseData['data']['token']);
        await UserStorage.saveUserInfo(responseData['data']['user']);
        Navigator.pushReplacementNamed(context, '/nav');
      } else if (response.statusCode == 500) {
        MessageModule(
            context, 'Помилка сервера. Спробуйте пізніше.', MessageType.error);
      } else {
        MessageModule(
            context, 'Помилка входу. Спробуйте ще раз.', MessageType.error);
        print('Ошибка авторизации ${response.statusCode}: ${response.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: TTColors.background,
      backgroundColor: TTColors.background,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   title: const Text('Вхід'),
      //   centerTitle: true,
      // ),
      body: Center(
        child: _isLoading
            ? LoadingModule
            : SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipOval(
                            child: ImageFiltered(
                              imageFilter:
                                  ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                              child: Container(
                                width: 166,
                                height: 166,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.25),
                                      Colors.white.withOpacity(0.25),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Image.network(
                            LOGO_IMAGE_DEFAULT,
                            fit: BoxFit.contain,
                            height: 133,
                          ),
                        ],
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
                        icon: Icons.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Введіть номер телефону';
                          if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) return 'Невірний формат номеру телефону';
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      CustomInputField(
                        controller: _passwordController,
                        label: 'Пароль',
                        obscureText: true,
                        icon: Icons.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Введіть пароль';
                          return null;
                        },
                      ),
                      // TextFormField(
                      //   controller: _phoneController,
                      //   decoration: const InputDecoration(
                      //     labelText: 'Номер телефону',
                      //     prefixText: '+',
                      //   ),
                      //   keyboardType: TextInputType.phone,
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Введіть номер телефону';
                      //     } else if (!RegExp(r'^\+?\d{10,15}$')
                      //         .hasMatch(value)) {
                      //       return 'Невірний формат номеру телефону';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      // const SizedBox(height: 16),
                      // TextFormField(
                      //   controller: _passwordController,
                      //   decoration: const InputDecoration(
                      //     labelText: 'Пароль',
                      //   ),
                      //   obscureText: true,
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Введіть пароль';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      const SizedBox(height: 40),
                      GlowingButton(
                        text: 'Увійти',
                        colorGrowing: Colors.white,
                        onPressed: () {
                          _submitForm();
                        },
                      ),
                      const SizedBox(height: 150),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
