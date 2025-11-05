import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tt_club_ua/Storage/Auth/ChangePasswordDto.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/api/routs/auth.dart';
import 'package:tt_club_ua/api/routs/root.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import '../../config/default.dart';
import '../buttons/CircleButton.dart';
import '../inputs/CustomInputField.dart';

class ChangePasswordSection extends StatefulWidget {
  final VoidCallback? onSuccess;

  const ChangePasswordSection({super.key, this.onSuccess});

  @override
  State<ChangePasswordSection> createState() => _ChangePasswordSectionState();
}

class _ChangePasswordSectionState extends State<ChangePasswordSection> {
  final _formKey = GlobalKey<FormState>();
  final ChangePasswordDto _changePasswordDto = ChangePasswordDto();

  bool _isLoading = false;
  bool _obscureAll = true; // один переключатель для всех полей

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // подставляем новый пароль в confirm (автоматически)
    _changePasswordDto.confirmPasswordController.text =
        _changePasswordDto.newPasswordController.text;

    final token = await UserStorage.getToken();
    final res = await API_CHANGE_PASSWORD(token, _changePasswordDto);

    if (res.statusCode >= 400 && res.statusCode < 500) {
      MessageModule(
        context,
        'Схоже, введений поточний пароль не збігається. Перевір уважно.',
        MessageType.error,
      );
      setState(() => _isLoading = false);
      return;
    }
    final isSuccess = await CHECK_API(res, context);

    if (!isSuccess) {
      setState(() => _isLoading = false);
      return;
    }

    MessageModule(
      context,
      'Новий пароль прийняв. Повний контроль — у твоїх руках.',
      MessageType.success,
    );

    widget.onSuccess?.call();
    setState(() => _isLoading = false);
  }

  void _toggleVisibility() {
    setState(() => _obscureAll = !_obscureAll);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Змінити пароль:',
            style: TTTextStyle.subtitle.copyWith(color: TTColors.text),
          ),
          Row(
            children: [
              CircleButton(
                iconAsset: _obscureAll
                    ? 'assets/svg/eye_closed.svg'
                    : 'assets/svg/eye.svg',
                onTap: _toggleVisibility,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomInputField(
                  controller: _changePasswordDto.oldPasswordController,
                  label: 'Старий пароль',
                  obscureText: _obscureAll,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Введіть старий пароль'
                      : null,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CustomInputField(
                  controller: _changePasswordDto.newPasswordController,
                  label: 'Новий пароль',
                  obscureText: _obscureAll,
                  // onChanged: (value) {
                  //   // сразу копируем в confirm
                  //   _changePasswordDto.confirmPasswordController.text = value;
                  // },
                  validator: (value) => value != null && value.length >= 4
                      ? null
                      : 'Пароль має бути від 4 символів',
                ),
              ),
              const SizedBox(width: 12),
              CircleButton(
                iconAsset: 'assets/svg/check_mark.svg',
                isLoading: _isLoading,
                onTap: _isLoading ? null : _changePassword,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
