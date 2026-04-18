import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/api/routs.dart';
import 'package:tt_club_ua/api/routs/Dto/Car/CarDto.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/components/layout/TTScaffold.dart';
import 'package:tt_club_ua/components/inputs/CustomInputField.dart';
import 'package:tt_club_ua/components/buttons/GlowingButton.dart';
import 'package:tt_club_ua/Storage/Cache/AccentColorCache.dart';

import '../../../Storage/UserStorage.dart';
import '../../../api/routs/Dto/Car/ColorDto.dart';
import '../../../api/routs/car/car.dart';
import '../../../api/routs/root.dart';
import '../../../components/generalModule.dart';
import '../../../components/viewers/ConfirmAndRun.dart';

class EditCarScreen extends StatefulWidget {
  final CarDto car;

  const EditCarScreen({super.key, required this.car});

  @override
  State<EditCarScreen> createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  late Color accentColor;
  List<ColorDto> _colors = [];
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchColors();
    accentColor = AccentColorCache.accentColor;
  }

// Додай на початку класу, якщо плануєш використовувати Form
// final _formKey = GlobalKey<FormState>();
  Future<void> _fetchColors() async {
    try {
      final token = await UserStorage.getToken();
      final resColors = await GET_COLORS(
          token); // Переконайся, що GET_COLORS повертає Response

      setState(() {
        _colors = (resColors.data['data'] as List)
            .map((item) => ColorDto.fromJson(item ?? {}))
            .toList();
      });
    } catch (e) {
      print('Помилка завантаження кольорів: $e');
    }
  }

  Future<void> _saveCar() async {
    // 1. Початок завантаження
    setState(() => isSaving = true);

    try {
      final token = await UserStorage.getToken();

      final res = await UPLOAD_CAR_BY_ID(token, widget.car);
      final isSuccess = await CHECK_API(res, context);

      if (isSuccess) {
        MessageModule(context, 'Авто успішно оновлено!', MessageType.success);

        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      MessageModule(context, 'Помилка зв\'язку з сервером', MessageType.error);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _deleteCar() async {
    setState(() => isSaving = true);

    try {
      final token = await UserStorage.getToken();
      final res = await CAR_DELETE_MINE(token, widget.car.id!);
      final isSuccess = await CHECK_API(res, context);

      // await Future.delayed(const Duration(seconds: 1)); // Імітація
      if (isSuccess) {
        MessageModule(context, 'Авто успішно видалено!', MessageType.success);
        if (mounted) Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Audi ${widget.car.model.name}',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildInfoRow(
              label: 'Покоління',
              value: widget.car.gene.name,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              label: 'Модель',
              value: widget.car.model.name,
            ),
            const SizedBox(height: 24),

            CustomInputField(
              controller: widget.car.vinCodeController,
              label: 'VIN код',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomInputField(
                    readOnly: true,
                    controller: widget.car.licensePlateController,
                    label: 'Держ. номер',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomInputField(
                    controller: widget.car.personalizedLicensePlateController,
                    label: 'Іменний номер',
                  ),
                ),
              ],
            ),
            // ... після селекторів Покоління та Модель ...
            const Divider(color: Colors.white10, height: 32),

            Text(
              'Колір кузова',
              style: TTTextStyle.subtitle.copyWith(color: TTColors.text),
            ),
            const SizedBox(height: 16),

// Якщо кольори ще завантажуються
            if (_colors.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 18,
                runSpacing: 14,
                children: _colors.map((c) {
                  final bool isActive = widget.car.color.id == c.id;
                  final Color hexColor = _parseColor(c.hex);
                  return GestureDetector(
                    onTap: () => setState(() {
                      widget.car.color = c;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive
                              ? hexColor
                              : Colors.white.withOpacity(0.1),
                          width: isActive ? 2.5 : 1,
                        ),
                        boxShadow: [
                          // мягкая «неоновая» подсветка у выбранного
                          if (isActive)
                            BoxShadow(
                              color: hexColor.withOpacity(0.35),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: hexColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 12),
// Показуємо назву обраного кольору під кульками
            Text(
              'Обрано: ${widget.car.color.name.isEmpty ? "не визначено" : widget.car.color.name}',
              style: TTTextStyle.subtitle.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 40),
            GlowingButton(
              text: isSaving ? 'Збереження...' : 'Зберегти зміни',
              colorGrowing: accentColor,
              onPressed: isSaving ? () {} : _saveCar,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 34, bottom: 20),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    ConfirmAndRun(
                      context: context,
                      dialogTitle: 'Видалити Audi ${widget.car.model.name}?',
                      dialogMessage:
                          'Ви продали своє авто та впевнені, що хочете видалити цю Audi ${widget.car.model.name} з гаража? Усі дані авто будуть втрачені.',
                      action:
                          _deleteCar, // Твій метод, який видаляє саме ID машини, а не юзера
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Видалити Audi ${widget.car.model.name} з гаража',
                      style: TTTextStyle.subtitle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Color _parseColor(String? hex) {
    // Якщо null або порожньо — повертаємо білий
    if (hex == null || hex.isEmpty) return Colors.white;

    try {
      final String cleanHex = hex.replaceAll('#', '');

      // Перевіряємо, чи рядок має валідну довжину для кольору (6 символів)
      if (cleanHex.length == 6) {
        return Color(int.parse('0xFF$cleanHex'));
      }

      // Якщо довжина не 6 (наприклад, коротка назва), теж повертаємо білий
      return Color(0xFFC0C0C0);
    } catch (e) {
      // Якщо сталася помилка парсингу (неваліді символи) — білий
      return Colors.white;
    }
  }
  // Плитка для вибору (Gene/Model/Color)
  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TTTextStyle.subtitle.copyWith(
            color: TTColors.text_secondary.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        Text(
          value.isEmpty ? '—' : value,
          style: TTTextStyle.subtitle.copyWith(
            color: TTColors.text.withOpacity(0.9),
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
