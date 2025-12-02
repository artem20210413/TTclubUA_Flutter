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
  final EventDto? item; // 👈 список возможных типів подій

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

    setState(() {
      _isLoading = true;
    });
    _fetchEventType();
    // если пришёл существующий ивент — редактируем, иначе создаём новый
    _event = widget.item ?? EventDto.empty();
  }

  Future<void> _fetchEventType() async {
    final token = await UserStorage.getToken();

    final res = await EVENT_TYPE_LIST(token);

    final isSuccess = await CHECK_API(res, context);

    if (!isSuccess) return;

    final data = jsonDecode(res.body)['data'] as List;

    final newItems = data.map((e) => EventTypeDto.fromJson(e)).toList();

    setState(() {
      allTypes = newItems;

      _isLoading = false;
    });
  }

  Future<void> _saveEvent() async {
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

  Future<void> _pickEventDate() async {
    final now = DateTime.now();
    final initial = _event.eventDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        // можно оформить в твоём стиле
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: TTColors.card,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _event.eventDate = picked;
      });
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'Оберіть дату';
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year}';
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
                    if (_event.id != null)
                      GoodsImagesEditor(
                        images: _event.images,
                        accentColor: accentColor,
                        onAdd: _addImage,
                        onDelete: _deleteImage,
                      ),
                    if (_event.id != null) const SizedBox(height: 24),

                    /// Назва
                    CustomInputField(
                      controller: _event.titleController,
                      label: 'Назва події',
                      validator: (v) => (v == null || v.trim().isEmpty)
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

                    /// Тип події
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Тип події',
                        style: TTTextStyle.subtitle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // TTSelect<EventTypeDto>(
                    //   value: _event.eventType,
                    //   items: allTypes,
                    //   labelBuilder: (t) => t.name,
                    //   onChanged: (v) {
                    //     if (v == null) return;
                    //     setState(() {
                    //       _event.eventType = v;
                    //     });
                    //   },
                    // ),
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
