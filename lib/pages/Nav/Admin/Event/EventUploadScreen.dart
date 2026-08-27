import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/Storage/Search/ImageUrlDto.dart';
import 'package:tt_club_ua/api/routs/Dto/Event/EventDto.dart';
import 'package:tt_club_ua/api/routs/root.dart';
import 'package:tt_club_ua/components/TTCheckbox.dart';
import 'package:tt_club_ua/components/TTLoading.dart';
import 'package:tt_club_ua/components/buttons/GlowingButton.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/components/inputs/BigTextInput.dart';
import 'package:tt_club_ua/components/inputs/CustomInputField.dart';
import 'package:tt_club_ua/components/layout/TTScaffold.dart';
import 'package:tt_club_ua/components/viewers/GoodsImagesEditor.dart';
import 'package:tt_club_ua/components/viewers/PickAndCropImage.dart';
import 'package:tt_club_ua/components/Selects/TTSelect.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../api/routs/Dto/Event/EventTypeDto.dart';
import '../../../../api/routs/events.dart';

class EventUploadScreen extends StatefulWidget {
  final EventDto? item;

  const EventUploadScreen({
    super.key,
    this.item,
  });

  @override
  State<EventUploadScreen> createState() => _EventUploadScreenState();
}

class _EventUploadScreenState extends State<EventUploadScreen> {
  List<EventTypeDto> allTypes = [];
  final _formKey = GlobalKey<FormState>();
  late EventDto _event;
  bool _isLoading = false;

  Color accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();

    _isLoading = true;
    _event = widget.item ?? EventDto.empty();
    _fetchEventType();
  }

  Future<void> _fetchEventType() async {
    final token = await UserStorage.getToken();
    final res = await EVENT_TYPE_LIST(token);

    final isSuccess = await CHECK_API(res, context);

    if (!isSuccess) return;

    final data = jsonDecode(res.body)['data'] as List;
    final loaded = data.map((e) => EventTypeDto.fromJson(e)).toList();

    setState(() {
      allTypes = loaded;

      // выбираем тип из списка
      final match = allTypes.firstWhere(
        (t) => t.id == _event.eventType.id,
        orElse: () => allTypes.first,
      );

      _event.eventType = match;

      _isLoading = false;
    });
  }

  Future<void> _saveEvent() async {
    // print(_event.toJson());
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final token = await UserStorage.getToken();
    final bool isEdit = _event.id != null;
    final res = isEdit
        ? await EDENT_UPLOAD(token, _event)
        : await EDENT_CREATE(token, _event);

    final isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      final body = jsonDecode(res.body);
      if (body['data'] != null) {
        setState(() {
          _event = EventDto.fromJson(body['data']); // если есть fromJson
        });
      }

      MessageModule(
        context,
        isEdit ? 'Подію успішно оновлено!' : 'Подію успішно створено!',
        MessageType.success,
      );

      Navigator.pop(context, true);
    } else {
      MessageModule(
        context,
        'Щось пішло не так...',
        MessageType.error,
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _addImage() async {
    final File? croppedFile = await pickAndCropImage(
      context: context,
      aspectRatio: null,
    );

    if (croppedFile == null) return;

    final token = await UserStorage.getToken();
    final res = await EVENT_IMAGE_ADD(
      token,
      _event.id ?? 0, // id уже должен быть (редактирование)
      croppedFile.path,
    );

    final isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      final body = jsonDecode(res.body);
      final imgJson = body['data']['images'].last;

      setState(() {
        _event.images.add(ImageUrlDto.fromJson(imgJson));
      });
    }
  }

  Future<void> _deleteImage(ImageUrlDto img, int index) async {
    final token = await UserStorage.getToken();
    final res = await EVENT_IMAGE_DELETE(token, _event.id ?? 0, img);

    final isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      setState(() {
        _event.images.removeAt(index);
      });

      MessageModule(
        context,
        'Фото успішно видалено',
        MessageType.success,
      );
    } else {
      MessageModule(
        context,
        'Помилка при видаленні фото',
        MessageType.error,
      );
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Оберіть дату';
    return "${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}";
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return 'Оберіть час';
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _pickEventDate() async {
    final now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _event.eventDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: accentColor,
              onPrimary: Colors.white,
              surface: TTColors.background,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // якщо вже є час — зберегти годину
      final old = _event.eventDate ?? now;

      setState(() {
        _event.eventDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          old.hour,
          old.minute,
        );
      });
    }
  }

  Future<void> _pickEventTime() async {
    final old = _event.eventDate ?? DateTime.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(old),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: TTColors.background,
              dialHandColor: accentColor,
              hourMinuteColor: Colors.transparent,
              hourMinuteTextColor: Colors.white,
              dayPeriodColor: TTColors.background,
              dayPeriodTextColor: Colors.white,
              entryModeIconColor: Colors.white,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _event.eventDate = DateTime(
          old.year,
          old.month,
          old.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _event.id != null;

    return TTScaffold(
      title: isEdit ? 'Редагування події' : 'Нова подія',
      body: _isLoading
          ? const TTLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Блок фото (только если событие уже создано и есть id)
                    if (isEdit)
                      GoodsImagesEditor(
                        images: _event.images,
                        accentColor: accentColor,
                        onAdd: _addImage,
                        onDelete: _deleteImage,
                      ),
                    if (isEdit) const SizedBox(height: 24),

                    /// Назва
                    CustomInputField(
                      controller: _event.titleController,
                      label: 'Назва події',
                      validator: (_) => (_event.titleController.value
                              .toString()
                              .trim()
                              .isEmpty)
                          ? 'Вкажіть назву події'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    /// Опис
                    BigTextInput(
                      controller: _event.descriptionController,
                      hint: 'Опис події',
                      minHeight: 80,
                      minLines: 3,
                    ),
                    const SizedBox(height: 12),

                    /// Місце
                    CustomInputField(
                      controller: _event.placeController,
                      label: 'Місце проведення',
                    ),
                    const SizedBox(height: 12),

                    /// Google Maps URL
                    CustomInputField(
                      controller: _event.googleMapsController,
                      label: 'Посилання на Google Maps',
                    ),
                    const SizedBox(height: 16),

                    /// Тип події
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Тип події',
                        style: TTTextStyle.subtitle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    allTypes.isEmpty
                        ? const TTLoading()
                        : SingleChildScrollView(
                            child: TTSelect<EventTypeDto>(
                              value: _event.eventType,
                              items: allTypes,
                              labelBuilder: (t) => t.name,
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() => _event.eventType = v);
                              },
                            ),
                          ),
                    const SizedBox(height: 16),

                    /// Дата події
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Дата події',
                        style: TTTextStyle.subtitle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickEventDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: TTColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: TTColors.text_secondary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(_event.eventDate),
                              style: TTTextStyle.subtitle,
                            ),
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// Час події
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Час події',
                        style: TTTextStyle.subtitle,
                      ),
                    ),
                    const SizedBox(height: 6),

                    GestureDetector(
                      onTap: _pickEventTime,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: TTColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: TTColors.text_secondary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(_event.eventDate),
                              style: TTTextStyle.subtitle,
                            ),
                            const Icon(Icons.schedule, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// Активність
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Статус',
                          style: TTTextStyle.subtitle,
                        ),
                        TTCheckbox(
                          activeNotifier: _event.activeNotifier,
                          accentColor: accentColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    /// Кнопка збереження
                    GlowingButton(
                      text: isEdit ? 'Оновити подію' : 'Створити подію',
                      colorGrowing: accentColor,
                      onPressed: _isLoading ? () {} : _saveEvent,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
