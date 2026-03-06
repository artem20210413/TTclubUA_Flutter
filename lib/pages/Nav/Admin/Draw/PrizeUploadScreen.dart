import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tt_club_ua/config/default.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/Search/ImageUrlDto.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Draw/draws.dart';
import '../../../../api/routs/Draw/prize.dart';
import '../../../../api/routs/Dto/Draw/PrizeDto.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/TTValidators.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/inputs/CustomInputField.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/viewers/GoodsImagesEditor.dart';
import '../../../../components/viewers/PickAndCropImage.dart';
import '../../../../components/buttons/GlowingButton.dart';

class PrizeUploadScreen extends StatefulWidget {
  final int drawId;
  final PrizeDto? prize;

  const PrizeUploadScreen({super.key, required this.drawId, this.prize});

  @override
  State<PrizeUploadScreen> createState() => _PrizeUploadScreenState();
}

class _PrizeUploadScreenState extends State<PrizeUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  late PrizeDto item;
  bool _isLoading = false;
  Color accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();
    item = widget.prize ?? PrizeDto.empty(drawId: widget.drawId);
  }

  Future<void> _savePrize() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final token = await UserStorage.getToken();
    final bool isEdit = item.id != null;

    // Для MultipartRequest завантаження файлів при створенні
    final res = isEdit
        ? await DRAW_PRIZE_UPLOAD(token, item, null)
        : await DRAW_PRIZE_CREATE(token, item, null);

    if (await CHECK_API(res, context)) {
      MessageModule(context, isEdit ? 'Оновлено!' : 'Створено!', MessageType.success);
      Navigator.pop(context, true);
    }
    setState(() => _isLoading = false);
  }

  void _addImage() async {
    if (item.id == null) {
      MessageModule(context, 'Спочатку збережіть приз', MessageType.information);
      return;
    }

    final File? croppedFile = await pickAndCropImage(context: context, aspectRatio: 1.0);
    if (croppedFile == null) return;

    setState(() => _isLoading = true);
    final token = await UserStorage.getToken();
    final res = await DRAW_PRIZE_IMAGE_ADD(token, item, croppedFile.path);

    if (await CHECK_API(res, context)) {
      final body = jsonDecode(res.body);
      final imgJson = body['data']['images'].last;
      setState(() {
        item.images.add(ImageUrlDto.fromJson(imgJson));
      });
    }
    setState(() => _isLoading = false);
  }

  void _deleteImage(ImageUrlDto img, int index) async {
    final token = await UserStorage.getToken();
    final res = await DRAW_PRIZE_DELETE(token, item, img);

    if (await CHECK_API(res, context)) {
      setState(() => item.images.removeAt(index));
      MessageModule(context, 'Фото видалено', MessageType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: item.id != null ? 'Редагувати приз' : 'Новий приз',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.id != null) ...[
                GoodsImagesEditor(
                  images: item.images,
                  accentColor: accentColor,
                  onAdd: _addImage,
                  onDelete: _deleteImage,
                ),
                const SizedBox(height: 24),
              ],

              CustomInputField(
                controller: item.titleController,
                label: 'Назва призу',
                validator: (v) => TTValidators.required(item.titleController.text),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  // Expanded(
                  //   child: CustomInputField(
                  //     controller: item.quantityController,
                  //     label: 'Кількість',
                  //     keyboardType: TextInputType.number,
                  //     // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  //   ),
                  // ),
                  // const SizedBox(width: 16),
                  Expanded(
                    child: CustomInputField(
                      controller: item.sortOrderController,
                      label: 'Сортування',
                      keyboardType: TextInputType.number,
                      // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              GlowingButton(
                text: _isLoading ? 'Збереження...' : 'Зберегти',
                onPressed: _isLoading ? () {} : _savePrize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}