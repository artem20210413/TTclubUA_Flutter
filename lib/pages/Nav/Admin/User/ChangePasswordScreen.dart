import 'package:flutter/material.dart';
import 'package:tt_club_ua/api/routs/User.dart'; // там должен быть твой метод USER_CHANGE_PASSWARD
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/generalModule.dart'; // для MessageModule
import 'dart:convert';

import '../../../../api/routs/Dto/User/UserUpdateDto.dart';
import '../../../../api/routs/root.dart';

class ChangePasswordScreen extends StatefulWidget {
  final UserUpdateDto userDto;

  const ChangePasswordScreen({super.key, required this.userDto});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final token = await UserStorage.getToken();
      final res = await USER_CHANGE_PASSWARD(
        token,
        widget.userDto.id,
        _passwordController.text,
      );


      final isSuccess = await CHECK_API(res, context);

      setState(() => _isLoading = false);

      if (isSuccess) {
        MessageModule(context, 'Пароль успішно змінено!', MessageType.success);
        Navigator.pop(context); // возвращаемся назад
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Зміна паролю')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Новий пароль'),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Пароль повинен містити мінімум 8 символів';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Підтвердьте пароль'),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Паролі не співпадають';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Змінити пароль'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
