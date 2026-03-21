import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/Search/ImageUrlDto.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Draw/draws.dart';
import '../../../../api/routs/Dto/Draw/DrawDto.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/TTCheckbox.dart';
import '../../../../components/TTValidators.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/inputs/BigTextInput.dart';
import '../../../../components/inputs/CustomInputField.dart';
import '../../../../components/inputs/PartnerDatePicker.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/viewers/ConfirmAndRun.dart';
import '../../../../components/viewers/GoodsImagesEditor.dart';
import '../../../../components/viewers/PickAndCropImage.dart';
import '../../../../components/buttons/GlowingButton.dart';
import 'ParticipantsListScreen.dart';
import 'PrizesListScreen.dart';

class DrawUploadScreen extends StatefulWidget {
  final DrawDto? draw;

  const DrawUploadScreen({super.key, this.draw});

  @override
  State<DrawUploadScreen> createState() => _DrawUploadScreenState();
}

class _DrawUploadScreenState extends State<DrawUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  late DrawDto item;
  bool _isLoading = false;
  Color accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();
    // Якщо об'єкт передано — редагуємо, інакше — створюємо порожній
    item = widget.draw ?? DrawDto.empty();
  }

  Future<void> _saveDraw() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final token = await UserStorage.getToken();
    final bool isEdit = item.id != null;

    final res = isEdit
        ? await DRAW_UPLOAD(token, item, null)
        : await DRAW_CREATE(token, item, null);
print(res.body);
    if (await CHECK_API(res, context)) {
      final body = jsonDecode(res.body);
      if (body['data'] != null) {
        setState(() {
          item = DrawDto.fromJson(body['data']);
        });
      }
      MessageModule(context, isEdit ? 'Оновлено!' : 'Створено!', MessageType.success);
      if (!isEdit) Navigator.pop(context, true); // Повертаємось до списку після створення
    }
    setState(() => _isLoading = false);
  }

  // Додавання головного фото розіграшу
  void _addImage() async {

    final File? croppedFile =
    await pickAndCropImage(context: context, aspectRatio: null);
    if (croppedFile == null) return;

    setState(() => _isLoading = true);
    final token = await UserStorage.getToken();
    // Метод додавання фото саме для акцій
    final res = await DRAW_IMAGE_ADD(
        token, item.id ?? 0, croppedFile.path);

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
    final res =
    await DRAW_IMAGE_DELETE(token, item.id ?? 0, img);

    if (await CHECK_API(res, context)) {
      setState(() => item.images.removeAt(index));
      MessageModule(context, 'Фото видалено', MessageType.success);
    }
  }

  Future<void> _deleteDraw() async {
    MessageModule(context, 'Забув.. треба зробити', MessageType.error);
    // final token = await UserStorage.getToken();
    // final res =
    // await DRAW_IMAGE_DELETE(token, item.id ?? 0, img);
    //
    // if (await CHECK_API(res, context)) {
    //   setState(() => item.images.removeAt(index));
    //   MessageModule(context, 'Фото видалено', MessageType.success);
    // }
  }
  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: item.id != null ? 'Редагувати розіграш' : 'Новий розіграш',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Секція фото (GoodsImagesEditor адаптований під Draw)
              if (item.id != null) ...[
                Text("Головне зображення", style: TTTextStyle.title.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
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
                label: 'Назва розіграшу',
                validator: (v) => TTValidators.required(item.titleController.text),
              ),
              const SizedBox(height: 16),

              BigTextInput(
                controller: item.descriptionController,
                hint: 'Опис та умови участі',
                minHeight: 100,
                validator: (v) => TTValidators.required(item.descriptionController.text),
              ),
              const SizedBox(height: 16),

              PartnerDatePicker(
                label: "Реєстрація до (дата та час)",
                value: item.registrationUntil,
                accentColor: accentColor,
                showTime: true,
                onChanged: (val) => setState(() => item.registrationUntil = val),
              ),
              const SizedBox(height: 16),

              TTCheckbox(
                label: 'Публічний розіграш',
                activeNotifier: item.isPublicNotifier,
                accentColor: accentColor,
              ),
              TTCheckbox(
                label: 'Дозволити декілька перемог одному юзеру',
                activeNotifier: item.allowMultipleWinsNotifier,
                accentColor: accentColor,
              ),

              const SizedBox(height: 32),

              GlowingButton(
                text: _isLoading ? 'Збереження...' : 'Зберегти зміни',
                onPressed: _isLoading ? () => {} : _saveDraw,
              ),

              // Якщо розіграш вже створено, показуємо кнопку переходу до призів
              if (item.id != null) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(color: accentColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PrizesListScreen(drawId: item.id!)),
                  ),
                  child: Text("Керувати призами (${item.prizes.length})", style: TextStyle(color: accentColor)),
                ),
              ],
              if (item.id != null) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide(color: accentColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ParticipantsListScreen(draw: item),
                      ),
                    );
                  },
                  child: Text("Керувати учасниками", style: TextStyle(color: accentColor)),
                ),
              ],

              Padding(
                padding: const EdgeInsets.only(top: 34, bottom: 16),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      ConfirmAndRun(
                        context: context,
                        dialogTitle: 'Видалити розіграш?',
                        dialogMessage:
                        'Цю дію неможливо скасувати. Розіграш і всі дані будуть видалені назавжди.',
                        action:
                        _deleteDraw, // 👈 тут просто передаём метод
                      );
                    },
                    child: Text(
                      'Видалити розіграш назавжди',
                      style: TTTextStyle.subtitle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}