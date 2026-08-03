import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/config/default.dart';

import '../components/TTLoading.dart';
import '../components/buttons/GlowingButton.dart';
import '../utils/url_launcher.dart';
import 'Auth/LoginPhonePasswordScreen.dart';
import 'Auth/LoginTgPhoneScreen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = true;
  String _phone = '';

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

  Future<void> _openTelegramLogin() async {
    // LoginTgPhoneScreen's back button (TTScaffold) pops with a bool, not a
    // String, so this must not force a String-typed push/result.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginTgPhoneScreen(initialPhone: _phone),
      ),
    );
    if (result is String && mounted) {
      setState(() {
        _phone = result;
      });
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
      setState(() {
        _phone = result;
      });
    }
  }

  final Uri _signupUri = Uri.parse(SIGNUP_URI);

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
                                  height: logoImageHeight,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 40 * scale),
                          Text('Вхід',
                              textAlign: TextAlign.center,
                              style: TTTextStyle.title),
                          SizedBox(height: 32 * scale),
                          GlowingButton(
                            text: 'Увійти через Telegram',
                            onPressed: _openTelegramLogin,
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: _openPhonePasswordLogin,
                              style: TextButton.styleFrom(
                                foregroundColor: TTColors.text_secondary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                              ),
                              child: const Text(
                                'Увійти за номером телефону',
                                style: TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 80 * scale),
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
                    );
                  },
                ),
        ),
      ),
    );
  }
}
