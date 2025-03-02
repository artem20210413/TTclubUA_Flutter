import 'package:flutter/cupertino.dart';

class ChangePasswordDto {
  TextEditingController oldPasswordController;
  TextEditingController newPasswordController;
  TextEditingController confirmPasswordController;

  ChangePasswordDto({
    TextEditingController? oldPasswordController,
    TextEditingController? newPasswordController,
    TextEditingController? confirmPasswordController,
  })  : oldPasswordController =
            oldPasswordController ?? TextEditingController(),
        newPasswordController =
            newPasswordController ?? TextEditingController(),
        confirmPasswordController =
            confirmPasswordController ?? TextEditingController();

  /// Метод для конвертации объекта в JSON
  Map<String, dynamic> toJson() {
    return {
      'current_password': oldPasswordController.text.trim(),
      'new_password': newPasswordController.text.trim(),
      'new_password_confirmation': confirmPasswordController.text.trim(),
    };
  }
}
