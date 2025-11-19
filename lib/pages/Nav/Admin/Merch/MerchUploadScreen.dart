import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/api/routs/Dto/Goods/GoodsDto.dart';
import 'package:tt_club_ua/api/routs/goods.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/pages/Nav/Admin/Publication/CreatePostScreen.dart';

import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/Cache/DeviceInsetsCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/CustomAppBar.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../../components/card/GoodsCard.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/interface/SearchBarWidgetState.dart';
import '../../../../components/layout/TTScaffold.dart';

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
  Color accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();
    item = widget.item ?? GoodsDto.empty(); // 👈 если не передали — пустой
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
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: item.id != null ? 'Редагування мерчу' : 'Новий мерч',
      body: isLoading
          ? const TTLoading()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: item.titleController,
                      decoration: const InputDecoration(
                        labelText: 'Назва',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Вкажіть назву'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: item.descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Опис',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: item.priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ціна, грн',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // твоя красивая кнопка
                    GlowingButton(
                      text:
                          item.id != null ? 'Оновити товар' : 'Створити товар',
                      colorGrowing: accentColor,
                      onPressed: isLoading ? () {} : _saveGoods,
                      // если у кнопки есть флаг isLoading – можно передать его сюда
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
