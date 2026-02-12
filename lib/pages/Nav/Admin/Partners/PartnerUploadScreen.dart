import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/components/buttons/GlowingButton.dart';

import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Partners/PartnerDto.dart';
import '../../../../api/routs/Partners/partners.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/inputs/BigTextInput.dart';
import '../../../../components/inputs/CustomInputField.dart';
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
  Color accentColor = AccentColorCache.accentColor;

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
      item =
          widget.partner ?? PartnerDto.empty(); // 👈 если не передали — пустой
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
  Future<void> _selectDateTime(bool isStart) async {
    // 1. Вибір дати
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );

    if (date == null) return;

    // 2. Вибір часу
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    // 3. Об'єднання в один DateTime
    setState(() {
      final finalDateTime = DateTime(
        date.year, date.month, date.day, time.hour, time.minute,
      );

      if (isStart) {
        item.startDate = finalDateTime;
      } else {
        item.endDate = finalDateTime;
      }
    });
  }
  Widget _buildSimplePicker(String label, DateTime? value, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60)),
        const SizedBox(height: 5),
        InkWell(
          onTap: () => _selectDateTime(isStart),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? "${value.day}.${value.month} ${value.hour}:${value.minute}"
                        : "Обрати",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if (value != null)
                  GestureDetector(
                    onTap: () => setState(() {
                      if (isStart) item.startDate = null; else item.endDate = null;
                    }),
                    child: const Icon(Icons.close, color: Colors.red, size: 18),
                  )
                else
                  const Icon(Icons.calendar_month, color: Colors.white54, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
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
                controller: item.websiteUrlController,
                label: 'Сайт',
                // validator: (v) => (v == null || v.trim().isEmpty)
                //     ? 'Вкажіть назву'
                //     : null,
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: item.instagramUrlController,
                label: 'Посилання на instagram',
                // validator: (v) => (v == null || v.trim().isEmpty)
                //     ? 'Вкажіть назву'
                //     : null,
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: item.googleMapsUrlController,
                label: 'Google Maps',
                // validator: (v) => (v == null || v.trim().isEmpty)
                //     ? 'Вкажіть назву'
                //     : null,
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: item.priorityController,
                label: 'Пріорітет',
                // validator: (v) => (v == null || v.trim().isEmpty)
                //     ? 'Вкажіть назву'
                //     : null,
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildSimplePicker("Початок", item.startDate, true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSimplePicker("Кінець", item.endDate, false)),
                ],
              ),

              const SizedBox(height: 32),
              // Ваша кнопка збереження
              GlowingButton(
                text: _isLoading ? 'Зберігання...' : 'Зберегти зміни',
                onPressed: _isLoading ? () => {} : _savePartner,
              ),

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
