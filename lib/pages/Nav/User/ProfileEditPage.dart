import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Storage/Cache/AccentColorCache.dart';
import '../../../Storage/UserStorage.dart';
import '../../../api/routs/Dto/City/CityDto.dart';
import '../../../api/routs/Dto/User/UserUpdateDto.dart';
import '../../../api/routs/User.dart';
import '../../../api/routs/cities/city.dart';
import '../../../api/routs/root.dart';
import '../../../components/TTLoading.dart';
import '../../../components/TTNeumorphicBox.dart';
import '../../../components/buttons/GlowingButton.dart';
import '../../../components/generalModule.dart';
import '../../../components/inputs/BigTextInput.dart';
import '../../../components/inputs/CitiesPicker.dart';
import '../../../components/inputs/CustomInputField.dart';
import '../../../components/inputs/TTFormField.dart';
import '../../../components/layout/TTScaffold.dart';
import '../../../config/default.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  late UserUpdateDto _dto;
  bool _loading = true;
  bool _saving = false;
  final accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final dynamic jsonUser = await UserStorage.getUserInfo();
    final isAdmin = await UserStorage.isAdmin(); // если нужно

    if (!mounted) return;
    setState(() {
      _dto = UserUpdateDto.fromJson(jsonUser);
      _loading = false;
    });
  }

  Future<void> _saveUser() async {
    if (_saving) return;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _saving = true);

      final token = await UserStorage.getToken();
      final res = await UPLOAD_USER(token, _dto);
      final isSuccess = await CHECK_API(res, context);

      if (isSuccess) {
        UserStorage.saveUserInfo(json.decode(res.body)['data']['user']);
        MessageModule(
            context, 'Профіль успішно оновлено!', MessageType.success);
      }

      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    DateTime? birthDate = null;
    // если уже есть дата в формате YYYY-MM-DD — попробуем распарсить
    final raw = _dto.birthDateController.text.trim();
    if (raw.isNotEmpty) {
      try {
        // print(raw);
        // birthDate = DateTime.parse(raw); //05-01-2001
        birthDate = DateFormat('dd-MM-yyyy').parse(raw);
      } catch (_) {
      }
    }
    DateTime initial = birthDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      final mm = picked.month.toString().padLeft(2, '0');
      final dd = picked.day.toString().padLeft(2, '0');
      _dto.birthDateController.text = '${picked.year}-$mm-$dd';
      setState(() {});
    }
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Text(
        text,
        style: TextStyle(
          color: TTColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Редагування профілю',
      body: _loading
          ? const TTLoading()
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
                  children: [
                    // --- Основні дані ---
                    _sectionTitle('Основні дані'),
                    CustomInputField(
                      controller: _dto.nameController,
                      label: 'Ім\'я',
                      validator: (_) {
                        final v = _dto.nameController.text;
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return "Вкажіть ім'я";
                        if (s.length < 2) return "Занадто коротко";
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    TTFormField(
                      label: "Дата народження",
                      hint: "YYYY-MM-DD",
                      controller: _dto.birthDateController,
                      readOnly: true,
                      onTap: _pickBirthDate,
                      suffix: Icon(Icons.calendar_month,
                          color: TTColors.text_secondary),
                    ),
                    const SizedBox(height: 10),
                    CustomInputField(
                      controller: _dto.emailController,
                      keyboardType: TextInputType.emailAddress,
                      label: 'Email',
                      validator: (_) {
                        final v = _dto.emailController.text;
                        final s = (v ?? '').trim();
                        if (s.isEmpty)
                          return null; // email может быть необязательным
                        final ok =
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
                        return ok ? null : "Некоректний email";
                      },
                    ),

                    _sectionTitle('Контакти та соцмережі'),

                    CustomInputField(
                      controller: _dto.telegramNicknameController,
                      label: 'Telegram',
                      readOnly: true, // НЕЛЬЗЯ редактировать
                    ),

                    const SizedBox(height: 10),

                    CustomInputField(
                      controller: _dto.phoneController,
                      label: 'Телефон',
                      readOnly: true, // НЕЛЬЗЯ редактировать
                    ),

                    const SizedBox(height: 10),

                    CustomInputField(
                      controller: _dto.instagramNicknameController,
                      label: 'Instagram', // НЕЛЬЗЯ редактировать
                    ),

                    // --- Про себе ---
                    _sectionTitle('Про себе'),
                    BigTextInput(
                      controller: _dto.occupationDescriptionController,
                      label: 'Яка твоя сфера діяльності?',
                      hint: 'Я займаюсь...',
                      minHeight: 50,
                      minLines: 1,
                    ),

                    const SizedBox(height: 10),

                    BigTextInput(
                      controller: _dto.whyTTController,
                      label: 'Чому саме TT?',
                      hint: 'Тому, що ТТ...',
                      minHeight: 50,
                      minLines: 1,
                    ),

                    _sectionTitle('Місто(а)'),
                    UserCitiesPicker(
                      currentCities: _dto.cities,
                      onChanged: (newCities) {
                        setState(() {
                          _dto.cities = newCities;
                          _dto.citiesText = newCities.isEmpty
                              ? 'Міста не вказані'
                              : newCities.map((c) => c.name).join(', ');
                        });
                      },
                    ),

                    const SizedBox(height: 18),
                    GlowingButton(
                      text: 'Зберегти зміни',
                      colorGrowing: accentColor,
                      onPressed: _saving ? () => {} : _saveUser,
                      // isLoading: _isLoadingSubmit,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Телефон і Telegram-нікнейм змінюються окремо та тут недоступні для редагування.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TTColors.text_secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
