import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tt_club_ua/components/generalModule.dart';
import 'dart:convert';

import '../../../Storage/Auth/ChangePasswordDto.dart';
import '../../../Storage/UserStorage.dart';
import '../../../api/routs/auth.dart';
import '../../../api/routs/root.dart';

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
      return;
    }
    // if (response.statusCode != 200) {
    //   // const body = response.
    //   MessageModule(context, 'error', MessageType.error);
    //   setState(() => _isLoading = false);
    //   return;
    // }

    MessageModule(context, 'Пароль успішно змінено.', MessageType.success);
    Navigator.pop(context);

    // final response = await http.post(
    //   Uri.parse('https://твой-сервер.com/api/change-password'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({
    //     'old_password': _oldPasswordController.text,
    //     'new_password': _newPasswordController.text,
    //   }),
    // );

    setState(() => _isLoading = false);

    // if (response.statusCode == 200) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Пароль успешно изменен!')),
    //   );
    //   _changePasswordDto.oldPasswordController.clear();
    //   _changePasswordDto.newPasswordController.clear();
    //   _changePasswordDto.confirmPasswordController.clear();
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //         content: Text('Ошибка: ${jsonDecode(response.body)['message']}')),
    //   );
    // }
  }

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
              TextFormField(
                controller: _changePasswordDto.oldPasswordController,
                decoration: InputDecoration(labelText: 'Старий пароль'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Введіть старий пароль' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _changePasswordDto.newPasswordController,
                decoration: InputDecoration(labelText: 'Новий пароль'),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? 'Пароль має бути від 6 символів' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _changePasswordDto.confirmPasswordController,
                decoration: InputDecoration(labelText: 'Підтвердьте пароль'),
                obscureText: true,
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
