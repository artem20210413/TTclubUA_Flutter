import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/components/buttons/GlowingButton.dart';

import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Partners/PartnerDto.dart';
import '../../../../api/routs/Partners/partners.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/layout/TTScaffold.dart';

class PartnerUploadScreen extends StatefulWidget {
  final PartnerDto? partner;

  const PartnerUploadScreen({super.key, this.partner});

  @override
  State<PartnerUploadScreen> createState() => _PartnerUploadScreenState();
}

class _PartnerUploadScreenState extends State<PartnerUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  late PartnerDto item;

  late TextEditingController _nameController;
  late TextEditingController _descController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.partner?.titleController.text ?? '');
    _descController = TextEditingController(
        text: widget.partner?.descriptionController.text ?? '');
    setState(() {
      item = widget.partner ?? PartnerDto.empty(); // 👈 если не передали — пустой
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
      MessageModule(
        context,
        'Щось пішло не так...',
        MessageType.error,
      );
    }

    setState(() => _isLoading = false);
    Navigator.pop(context, item);
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
              // Здесь можно добавить ImagePicker для логотипа, как в EventUploadScreen
              const SizedBox(height: 20),
              // CustomInput(
              //   controller: _nameController,
              //   label: 'Назва партнера',
              //   placeholder: 'Введіть назву...',
              // ),
              // const SizedBox(height: 16),
              // CustomInput(
              //   controller: _descController,
              //   label: 'Опис',
              //   placeholder: 'Опис діяльності...',
              //   maxLines: 4,
              // ),
              const SizedBox(height: 32),

              if (isEdit) ...[
                GlowingButton(
                  text: 'Перейти до акцій',
                  colorGrowing: Colors.blueAccent,
                  onPressed: () {
                    // Переход к списку акций этого партнера
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => PartnerPromotionsScreen(partnerId: widget.partner!.id)));
                  },
                ),
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
