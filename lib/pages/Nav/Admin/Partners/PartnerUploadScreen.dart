import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/components/buttons/GlowingButton.dart';

import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/Search/ImageUrlDto.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Partners/PartnerDto.dart';
import '../../../../api/routs/Partners/partners.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/TTCheckbox.dart';
import '../../../../components/TTValidators.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/inputs/BigTextInput.dart';
import '../../../../components/inputs/CustomInputField.dart';
import '../../../../components/inputs/PartnerDatePicker.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/viewers/GoodsImagesEditor.dart';
import '../../../../components/viewers/PickAndCropImage.dart';
import 'PartnerPromotionsList.dart';

class PartnerUploadScreen extends StatefulWidget {
  final PartnerDto? partner;

  const PartnerUploadScreen({super.key, this.partner});

  @override
  State<PartnerUploadScreen> createState() => _PartnerUploadScreenState();
}

class _PartnerUploadScreenState extends State<PartnerUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  late PartnerDto item;
  Color accentColor = AccentColorCache.accentColor;

  late TextEditingController _nameController;
  late TextEditingController _descController;
  bool _isLoading = false;
  bool _canEditContent = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.partner?.titleController.text ?? '');
    _descController = TextEditingController(
        text: widget.partner?.descriptionController.text ?? '');
    setState(() {
      item =
          widget.partner ?? PartnerDto.empty(); // 👈 если не передали — пустой
    });
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final canEdit = await UserStorage.canEditContent();
    setState(() {
      _canEditContent = canEdit;
    });
  }

  Future<void> _savePartner() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final token = await UserStorage.getToken();
    final bool isEdit = item.id != null;
    final res = isEdit
        ? await PARTNERS_UPLOAD(token, item) // обновление
        : await PARTNERS_CREATE(token, item); // создание

    final isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      final body = jsonDecode(res.body);
      // если бэк возвращает объект товара в data — можно обновить локальный dto
      if (body['data'] != null) {
        setState(() {
          item = PartnerDto.fromJson(body['data']);
        });
      }

      MessageModule(
        context,
        isEdit ? 'Партнер успішно оновлено!' : 'Партнер успішно створено!',
        MessageType.success,
      );
    } else {
      print(jsonDecode(res.body));
      MessageModule(
        context,
        'Щось пішло не так...',
        MessageType.error,
      );
    }

    setState(() => _isLoading = false);
    Navigator.pop(context, item);
  }

  void _addImage() async {
    final File? croppedFile = await pickAndCropImage(
      context: context,
      aspectRatio: null,
    );
    if (croppedFile == null) return;

    final token = await UserStorage.getToken();
    final res = await PARTNERS_IMAGE_ADD(
      token,
      item.id ?? 0,
      croppedFile.path,
    );

    final isSuccess = await CHECK_API(res, context);
    if (isSuccess) {
      final body = jsonDecode(res.body);

      final imgJson = body['data']['photos'].last;

      setState(() {
        item.images.add(
          ImageUrlDto.fromJson(imgJson),
        );
      });
    } else {
      MessageModule(
        context,
        'Помилка при збереженні фото',
        MessageType.error,
      );
    }
  }

  void _deleteImage(ImageUrlDto img, int index) async {
    final token = await UserStorage.getToken();
    final res =
        await PARTNERS_IMAGE_DELETE(token, item.id ?? 1, img); // создание

    final isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      setState(() {
        item.images.removeAt(index);
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

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.partner != null;

    return TTScaffold(
      title: item.id != null ? 'Редагувати партнера' : 'Новий партнер',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (item.id != null)
                GoodsImagesEditor(
                  images: item.images,
                  accentColor: accentColor,
                  onAdd: _addImage,
                  onDelete: _canEditContent ? _deleteImage : null,
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: PartnerDatePicker(
                      label: "Дата початку",
                      value: item.startDate,
                      accentColor: accentColor,
                      showTime: false,
                      onChanged: (val) => setState(() => item.startDate = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PartnerDatePicker(
                      label: "Дата завершення",
                      value: item.endDate,
                      accentColor: accentColor,
                      showTime: false,
                      onChanged: (val) => setState(() => item.endDate = val),
                    ),
                  ),
                ],
              ),
              // Здесь можно добавить ImagePicker для логотипа, как в EventUploadScreen
              const SizedBox(height: 20),
              CustomInputField(
                controller: item.titleController,
                label: 'Назва',
                validator: (v) =>
                    TTValidators.required(item.titleController.text),
              ),
              const SizedBox(height: 12),
              BigTextInput(
                controller: item.descriptionController,
                hint: 'Опис',
                minHeight: 50,
                minLines: 1,
                validator: (v) =>
                    TTValidators.required(item.descriptionController.text),
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: item.websiteUrlController,
                label: 'Сайт',
                validator: (v) =>
                    TTValidators.url(item.instagramUrlController.text),
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: item.instagramUrlController,
                label: 'Посилання на instagram',
                validator: (v) =>
                    TTValidators.instagram(item.instagramUrlController.text),
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: item.googleMapsUrlController,
                label: 'Google Maps',
                validator: (v) =>
                    TTValidators.googleMaps(item.googleMapsUrlController.text),
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: item.priorityController,
                label: 'Пріорітет',
              ),

              const SizedBox(height: 12),
              TTCheckbox(
                label: 'Доступний для всіх',
                activeNotifier: item.activeNotifier,
                accentColor: accentColor,
              ),
              const SizedBox(height: 32),
              // Ваша кнопка збереження
              GlowingButton(
                  text: _isLoading ? 'Зберігання...' : 'Зберегти зміни',
                  onPressed: _isLoading ? () => {} : _savePartner,
                  colorGrowing: accentColor),

              const SizedBox(height: 32),
              if (isEdit) ...[
                GlowingButton(
                    text: 'Перейти до акцій',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PartnerPromotionsList(
                                  partner: widget.partner!)));
                    },
                    colorGrowing: accentColor),
                const SizedBox(height: 12),
              ],

              // GlowingButton(
              //   text: _isLoading ? 'Зберігання...' : 'Зберегти зміни',
              //   onPressed: _isLoading ? null : _savePartner,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
