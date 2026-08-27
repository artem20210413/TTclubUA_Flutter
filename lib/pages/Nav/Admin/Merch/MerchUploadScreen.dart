import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/api/routs/Dto/Goods/GoodsDto.dart';
import 'package:tt_club_ua/api/routs/goods.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/pages/Nav/Admin/Publication/CreatePostScreen.dart';

import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/Cache/DeviceInsetsCache.dart';
import '../../../../Storage/Search/ImageUrlDto.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/CustomAppBar.dart';
import '../../../../components/TTCheckbox.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../Home/Merch/GoodsCard.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/inputs/BigTextInput.dart';
import '../../../../components/inputs/CustomInputField.dart';
import '../../../../components/interface/SearchBarWidgetState.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/viewers/GoodsImagesEditor.dart';
import '../../../../components/viewers/PickAndCropImage.dart';

class MerchUploadScreen extends StatefulWidget {
  final GoodsDto? item; // 👈 товар может быть, а может и нет

  const MerchUploadScreen({
    super.key,
    this.item,
  });

  @override
  _MerchUploadScreenState createState() => _MerchUploadScreenState();
}

class _MerchUploadScreenState extends State<MerchUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  late GoodsDto item; // всегда не null внутри стейта
  bool isLoading = false;
  bool _canEditContent = false;
  Color accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();
    item = widget.item ?? GoodsDto.empty(); // 👈 если не передали — пустой
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final canEdit = await UserStorage.canEditContent();
    setState(() {
      _canEditContent = canEdit;
    });
  }

  Future<void> _saveGoods() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final token = await UserStorage.getToken();
    final bool isEdit = item.id != null;
    final res = isEdit
        ? await GOODS_UPLOAD(token, item) // обновление
        : await GOODS_CREATE(token, item); // создание

    final isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      final body = jsonDecode(res.body);
      // если бэк возвращает объект товара в data — можно обновить локальный dto
      if (body['data'] != null) {
        setState(() {
          item = GoodsDto.fromJson(body['data']);
        });
      }

      MessageModule(
        context,
        isEdit ? 'Товар успішно оновлено!' : 'Товар успішно створено!',
        MessageType.success,
      );
    } else {
      MessageModule(
        context,
        'Щось пішло не так...',
        MessageType.error,
      );
    }

    setState(() => isLoading = false);
    Navigator.pop(context, item);
  }

  void _addImage() async {
    final File? croppedFile = await pickAndCropImage(
      context: context,
      aspectRatio: null,
    );

    if (croppedFile == null) return;

    final token = await UserStorage.getToken();
    final res = await GOODS_IMAGE_ADD(
      token,
      item.id ?? 0,
      croppedFile.path,
    );

    final isSuccess = await CHECK_API(res, context);
    if (isSuccess) {
      final body = jsonDecode(res.body);

      final imgJson = body['data']['images'].last;

      setState(() {
        item.images.add(
          ImageUrlDto.fromJson(imgJson),
        );
      });
    }
  }

  void _deleteImage(ImageUrlDto img, int index) async {
    final token = await UserStorage.getToken();
    final res = await GOODS_IMAGE_DELETE(token, item.id ?? 1, img); // создание

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
    return TTScaffold(
      title: item.id != null ? 'Редагування мерчу' : 'Новий мерч',
      body: isLoading
          ? const TTLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                      const SizedBox(height: 24),
                      CustomInputField(
                        controller: item.titleController,
                        label: 'Назва',
                        // validator: (v) => (v == null || v.trim().isEmpty)
                        //     ? 'Вкажіть назву'
                        //     : null,
                      ),
                      const SizedBox(height: 12),
                      BigTextInput(
                        controller: item.descriptionController,
                        hint: 'Опис',
                        minHeight: 50,
                        minLines: 1,
                      ),
                      const SizedBox(height: 12),

                      CustomInputField(
                        controller: item.priceController,
                        keyboardType: TextInputType.number,
                        label: 'Ціна, грн',
                      ),
                      const SizedBox(height: 24),

                      CustomInputField(
                        controller: item.priorityController,
                        keyboardType: TextInputType.number,
                        label: 'Порядок',
                      ),
                      const SizedBox(height: 24),
                      TTCheckbox(
                        activeNotifier: item.activeNotifier,
                        accentColor: accentColor,
                      ),
                      const SizedBox(height: 24),

                      // твоя красивая кнопка
                      GlowingButton(
                        text: item.id != null
                            ? 'Оновити товар'
                            : 'Створити товар',
                        colorGrowing: accentColor,
                        onPressed: isLoading ? () {} : _saveGoods,
                        // если у кнопки есть флаг isLoading – можно передать его сюда
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
