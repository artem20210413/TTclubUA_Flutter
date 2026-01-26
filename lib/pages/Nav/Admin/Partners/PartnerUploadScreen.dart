import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/components/buttons/GlowingButton.dart';

import '../../../../api/routs/Dto/Partners/PartnerDto.dart';

class PartnerUploadScreen extends StatefulWidget {
  final PartnerDto? partner; // Если null — создание, если есть — редактирование

  const PartnerUploadScreen({super.key, this.partner});

  @override
  State<PartnerUploadScreen> createState() => _PartnerUploadScreenState();
}

class _PartnerUploadScreenState extends State<PartnerUploadScreen> {
  final _formKey = GlobalKey<FormState>();

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
  }

  Future<void> _savePartner() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    // Логика вызова API (создание или обновление)
    // await UPDATE_PARTNER(...) или CREATE_PARTNER(...)

    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.partner != null;

    return Scaffold(
      backgroundColor: TTColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Редагувати партнера' : 'Новий партнер',
            style: TTTextStyle.title18),
        backgroundColor: TTColors.background,
      ),
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
