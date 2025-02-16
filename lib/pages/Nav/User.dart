import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tt_club_ua/Storage/UserDto.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/api/routs/user.dart';
import 'package:tt_club_ua/api/routs/root.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../Storage/CityDto.dart';
import '../../api/routs/cities/CityServices.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  UserDTO _userDTO = UserDTO();
  List<CityDTO> _cities = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _telegramController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _clubEntryDateController =
      TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  String userProfileImage = USER_PROFILE_IMAGE_DEFAULT;

  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profileImage = await UserStorage.getProfileImagee();
    final dynamic json = await UserStorage.getUserInfo();

    final List<CityDTO> cities = await CityServices.getAllCities(context);

    setState(() {
      _userDTO = UserDTO.fromJson(json);
      _cities = cities;

      _nameController.text = _userDTO.name ?? '';
      _emailController.text = _userDTO.email ?? '';
      _phoneController.text = _userDTO.phone ?? '';
      _instagramController.text = _userDTO.instagramNickname ?? '';
      _telegramController.text = _userDTO.telegramNickname ?? '';
      _birthDateController.text = _userDTO.birthDate != null
          ? DateFormat(DATE_FORMAT_DEFAULT).format(_userDTO.birthDate!)
          : '';
      _clubEntryDateController.text = _userDTO.clubEntryDate != null
          ? DateFormat(DATE_FORMAT_DEFAULT).format(_userDTO.clubEntryDate!)
          : '';
      _occupationController.text = _userDTO.occupationDescription ?? '';
      userProfileImage = profileImage ?? userProfileImage;
    });

    // await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _userDTO.name = _nameController.text;
        _userDTO.email = _emailController.text;
        _userDTO.phone = _phoneController.text;
        _userDTO.instagramNickname = _instagramController.text;
        _userDTO.telegramNickname = _telegramController.text;
        _userDTO.birthDate =
            DateFormat(DATE_FORMAT_DEFAULT).parse(_birthDateController.text);
        _userDTO.clubEntryDate = DateFormat(DATE_FORMAT_DEFAULT)
            .parse(_clubEntryDateController.text);
        _userDTO.occupationDescription = _occupationController.text;
      });

      final token = await UserStorage.getToken();
      final res = await UPLOAD_USER(token, _userDTO);
      final isSuccess = await CHECK_API(res, context);

      if (isSuccess) {
        UserStorage.saveUserInfo(json.decode(res.body)['data']['user']);
        MessageModule(
            context, 'Profile updated successfully!', MessageType.success);
      }
    }
  }

  Future<void> _logout() async {
    await UserStorage.clearUserInfo();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
          ? CenterLoadingModule
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Фото профиля
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(userProfileImage),
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(height: 16),

                    // Имя пользователя
                    Text(
                      _nameController.text,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    _buildTextField('Name', _nameController, _validatorDefault),
                    _buildTextField(
                        'Email', _emailController, _validatorDefault,
                        keyboardType: TextInputType.emailAddress),
                    _buildPhoneField('Phone number', _phoneController,
                        isEditable: false),
                    _buildTextField('Instagram', _instagramController, null),
                    _buildTextField('Telegram', _telegramController, null),
                    _buildDatePickerField('Birth Date', _birthDateController),
                    _buildDatePickerField(
                        'Club Entry Date', _clubEntryDateController,
                        isEditable: false),
                    _buildTextField(
                        'Occupation', _occupationController, _validatorDefault,
                        maxLines: 5),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // Выравнивание по горизонтали
                      // crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание по вертикали
                      children: [
                        ElevatedButton(
                          onPressed: _saveUser,
                          child: const Text('Save'),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: _saveUser,
                          child: const Text('Change password'),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            _logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8B0000),
                          ),
                          child: const Text(
                            'Вихід',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, dynamic validator,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
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
      ),
    );
  }

  Widget _buildPhoneField(String label, TextEditingController controller,
      {bool isEditable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _phoneController,
        decoration: const InputDecoration(
          labelText: 'Номер телефону',
          prefixText: '+',
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
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

  Widget _buildDatePickerField(String label, TextEditingController controller,
      {bool isEditable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
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
              firstDate: DateTime(1900), // Самая ранняя дата
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

  final _validatorPhone = (String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    // Проверка на допустимость номера телефона (например, 10 цифр)
    final phoneRegex = RegExp(r'^\+?\d{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  };
  final _validatorDefault = (value) =>
      value == null || value.isEmpty ? 'This field is required' : null;
}
