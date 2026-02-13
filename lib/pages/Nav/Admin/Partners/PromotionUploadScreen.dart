import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/components/buttons/GlowingButton.dart';

import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/Search/ImageUrlDto.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Partners/PartnerDto.dart';
import '../../../../api/routs/Dto/Partners/PromotionDto.dart'; // Твій шлях до DTO
import '../../../../api/routs/Partners/partners.dart'; // Методи для акцій
import '../../../../api/routs/Partners/promotions.dart';
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

class PromotionUploadScreen extends StatefulWidget {
  final PromotionDto? promotion;
  final PartnerDto partner;

  const PromotionUploadScreen(
      {super.key, this.promotion, required this.partner});

  @override
  State<PromotionUploadScreen> createState() => _PromotionUploadScreenState();
}

class _PromotionUploadScreenState extends State<PromotionUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  late PromotionDto item;
  Color accentColor = AccentColorCache.accentColor;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Якщо передали об'єкт - редагуємо, якщо ні - створюємо порожній для партнера
    item = widget.promotion ??
        PromotionDto.empty(partnerId: widget.partner.id ?? 0);
  }

  Future<void> _savePromotion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final token = await UserStorage.getToken();
    final bool isEdit = item.id != null;

    // Припускаємо, що у тебе є відповідні методи в API
    final res = isEdit
        ? await PARTNERS_PROMOTIONS_UPLOAD(token, item)
        : await PARTNERS_PROMOTIONS_CREATE(token, item);

    print(jsonDecode(res.body));
    final isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      final body = jsonDecode(res.body);
      if (body['data'] != null) {
        setState(() {
          item = PromotionDto.fromJson(body['data']);
        });
      }

      MessageModule(
        context,
        isEdit ? 'Акцію успішно оновлено!' : 'Акцію успішно створено!',
        MessageType.success,
      );
      Navigator.pop(context, item);
    } else {
      MessageModule(context, 'Помилка при збереженні', MessageType.error);
    }

    setState(() => _isLoading = false);
  }

  void _addImage() async {
    final File? croppedFile =
        await pickAndCropImage(context: context, aspectRatio: null);
    if (croppedFile == null) return;

    final token = await UserStorage.getToken();
    // Метод додавання фото саме для акцій
    final res = await PARTNERS_PROMOTIONS_IMAGE_ADD(
        token, item.id ?? 0, croppedFile.path);

    if (await CHECK_API(res, context)) {
      final body = jsonDecode(res.body);
      final imgJson = body['data']['photos'].last;
      setState(() {
        item.images.add(ImageUrlDto.fromJson(imgJson));
      });
    }
  }

  void _deleteImage(ImageUrlDto img, int index) async {
    final token = await UserStorage.getToken();
    final res =
        await PARTNERS_PROMOTIONS_IMAGE_DELETE(token, item.id ?? 0, img);

    if (await CHECK_API(res, context)) {
      setState(() => item.images.removeAt(index));
      MessageModule(context, 'Фото видалено', MessageType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: widget.partner.titleController.text,
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
                  onDelete: _deleteImage,
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: PartnerDatePicker(
                      label: "Початок",
                      value: item.startDate,
                      accentColor: accentColor,
                      showTime: false,
                      onChanged: (val) => setState(() => item.startDate = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PartnerDatePicker(
                      label: "Кінець",
                      value: item.endDate,
                      accentColor: accentColor,
                      showTime: false,
                      onChanged: (val) => setState(() => item.endDate = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomInputField(
                controller: item.titleController,
                label: 'Назва акції',
                validator: (v) => TTValidators.required(item.titleController.text),
              ),
              const SizedBox(height: 12),
              BigTextInput(
                controller: item.descriptionController,
                hint: 'Опис пропозиції',
                minHeight: 80,
                validator: (v) =>
                    TTValidators.required(item.descriptionController.text),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      controller: item.discountValueController,
                      label: 'Знижка (н-ад: -10%)',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomInputField(
                      controller: item.promoCodeController,
                      label: 'Промокод',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: item.priorityController,
                label: 'Пріоритет',
                // Можна додати TTValidators.number якщо треба
              ),
              const SizedBox(height: 20),
              TTCheckbox(
                label: 'Активна пропозиція',
                activeNotifier: item.activeNotifier,
                accentColor: accentColor,
              ),
              const SizedBox(height: 8),
              TTCheckbox(
                label: 'Тільки для клубу (Exclusive)',
                activeNotifier: item.exclusiveNotifier,
                accentColor: Colors.amber,
              ),
              const SizedBox(height: 32),
              GlowingButton(
                text: _isLoading ? 'Збереження...' : 'Зберегти акцію',
                onPressed: _isLoading ? () => {} : _savePromotion,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
