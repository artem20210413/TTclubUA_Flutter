import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tt_club_ua/Storage/UserDto.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/api/routs/user.dart';
import 'package:tt_club_ua/api/routs/root.dart';
import 'package:tt_club_ua/config/default.dart';


Widget customBuildTextField(
    String label, TextEditingController controller, dynamic validator,
    {TextInputType keyboardType = TextInputType.text, int maxLines = 1, bool isEditable = true}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        // border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 24,
        ), // Уменьшенные отступы
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines, // Количество строк
      readOnly: !isEditable,
    ),
  );
}

Widget customBuildPhoneField(String label, TextEditingController controller,
    {bool isEditable = true}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Номер телефону',
        prefixText: '+',
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Введіть номер телефону';
        } else if (!RegExp(r'^\+?\d{12,15}$').hasMatch(value)) {
          return 'Невірний формат номеру телефону';
        }
        return null;
      },
      readOnly: !isEditable,
    ),
  );
}

Widget customBuildDatePickerField(
    String label, TextEditingController controller,  BuildContext context,
    {bool isEditable = true}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      ),
      readOnly: !isEditable,
      // Поле только для чтения, чтобы пользователь не мог вручную вводить текст
      onTap: () async {
        // Показываем DatePicker
        if (isEditable) {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialEntryMode: DatePickerEntryMode.input,
            initialDate: DateTime.tryParse(context.toString()),
            firstDate: DateTime(1900),
            // Самая ранняя дата
            lastDate: DateTime.now(), // Сегодняшний день как максимум
          );
          if (pickedDate != null) {
            // Форматируем дату и устанавливаем в контроллер
            controller.text =
                DateFormat(DATE_FORMAT_DEFAULT).format(pickedDate);
          }
        }
      },
    ),
  );
}

Widget customBuildPasswordField({
  required String label,
  required TextEditingController controller,
  required bool obscureText,
  required VoidCallback toggleObscure,
  required String? Function(String?) validator, // Валидатор
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: IconButton(
        icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: toggleObscure,
      ),
    ),
    obscureText: obscureText,
    validator: validator, // Переданный валидатор
  );
}

final customValidatorDefault = (value) =>
value == null || value.isEmpty ? 'This field is required' : null;
