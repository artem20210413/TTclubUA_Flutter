import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tt_club_ua/components/generalModule.dart';
import 'dart:convert';

import '../../../Storage/Auth/ChangePasswordDto.dart';
import '../../../Storage/UserStorage.dart';
import '../../../api/routs/auth.dart';
import '../../../api/routs/root.dart';
import '../../../components/form/FormElements.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  ChangePasswordDto _changePasswordDto = new ChangePasswordDto();

  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await UserStorage.getToken();
    final res = await API_CHANGE_PASSWORD(token, _changePasswordDto);

    final isSuccess = await CHECK_API(res, context);
    if (!isSuccess) {
      setState(() => _isLoading = false);
      return;
    }
    MessageModule(context, 'Новий пароль прийняв. Повний контроль — у твоїх руках.', MessageType.success);
    Navigator.pop(context);

    setState(() => _isLoading = false);
  }

  bool _obscureOldPassword = true; // Состояние скрытия пароля
  bool _obscureNewPassword = true; // Состояние скрытия пароля
  bool _obscureConfirmPassword = true; // Состояние скрытия пароля

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Зміна пароля')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customBuildPasswordField(
                label: 'Старий пароль',
                controller: _changePasswordDto.oldPasswordController,
                obscureText: _obscureOldPassword,
                toggleObscure: () {
                  setState(() {
                    _obscureOldPassword = !_obscureOldPassword;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Введіть старий пароль'
                    : null,
              ),
              SizedBox(height: 10),
              customBuildPasswordField(
                label: 'Новий пароль',
                controller: _changePasswordDto.newPasswordController,
                obscureText: _obscureNewPassword,
                toggleObscure: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
                validator: (value) =>
                    value!.length < 6 ? 'Пароль має бути від 6 символів' : null,
              ),
              SizedBox(height: 10),
              customBuildPasswordField(
                label: 'Підтвердьте пароль',
                controller: _changePasswordDto.confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                toggleObscure: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                validator: (value) =>
                    value != _changePasswordDto.newPasswordController.text
                        ? 'Паролі не збігаються'
                        : null,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CenterLoadingModule
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _changePassword,
                        child: Text('Змінити пароль'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
