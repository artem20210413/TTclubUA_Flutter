import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/api/routs/auth.dart';
import 'package:tt_club_ua/components/TTLoading.dart';
import 'package:tt_club_ua/components/buttons/GlowingButton.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/components/inputs/CustomInputField.dart';
import 'package:tt_club_ua/config/default.dart';
import '../../components/layout/TTScaffold.dart';

class LoginTgCodeScreen extends StatefulWidget {
  final String phone;

  const LoginTgCodeScreen({super.key, required this.phone});

  @override
  State<LoginTgCodeScreen> createState() => _LoginTgCodeScreenState();
}

class _LoginTgCodeScreenState extends State<LoginTgCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();

  bool _isLoading = false;

  // --- Таймер повторной отправки ---
  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _secondsLeft = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resendCode() async {
    setState(() => _isLoading = true);

    final res = await API_LOGIN_TG_SEND_CODE(widget.phone);

    if (res.statusCode == 200) {
      MessageModule(context, 'Код повторно надіслано в Telegram!', MessageType.success);
      _startTimer();
    } else {
      MessageModule(context, 'Не вдалося надіслати код', MessageType.error);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final code = _codeController.text.trim();
    final res = await API_LOGIN_TG_VERIFY(widget.phone, code);

    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);

      await UserStorage.saveToken(jsonData['data']['token']);
      await UserStorage.saveUserInfo(jsonData['data']['user']);

      MessageModule(context, 'Вітаємо у TT Club!', MessageType.success);

      Navigator.pushReplacementNamed(context, '/nav');
    } else {
      MessageModule(context, 'Невірний код', MessageType.error);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Підтвердження входу',
      body: Center(
        child: _isLoading
            ? const TTLoading()
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'На номер ${widget.phone} було надіслано код у Telegram.',
                  style: TTTextStyle.subtitle,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                CustomInputField(
                  controller: _codeController,
                  label: 'Код з Telegram',
                  keyboardType: TextInputType.number,
                  suffixIcon: SvgPicture.asset(
                    'assets/svg/lock.svg',
                    width: 36,
                    height: 36,
                    colorFilter: ColorFilter.mode(
                      TTColors.text_secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  validator: (_) {
                    final value = _codeController.text;
                    if (value.isEmpty) return 'Введіть код';
                    if (value.length < 3) return 'Невірний код';
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                GlowingButton(
                  text: 'Підтвердити',
                  onPressed: _confirm,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 32),

                // -------------- Повторная отправка --------------
                _secondsLeft > 0
                    ? Text(
                  'Повторна відправка через ${_secondsLeft} сек',
                  style: TTTextStyle.subtitle,
                )
                    : GestureDetector(
                  onTap: _resendCode,
                  child: Text(
                    'Надіслати код повторно',
                    style: TTTextStyle.subtitle.copyWith(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
