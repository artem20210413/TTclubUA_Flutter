import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../api/routs/Draw/draws.dart';
import '../../../../api/routs/Draw/participants.dart';
import '../../../../api/routs/Dto/Draw/ParticipantDto.dart';
import '../../../../api/routs/root.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../components/inputs/CustomInputField.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../../components/generalModule.dart';

class ParticipantEditScreen extends StatefulWidget {
  final int drawId;
  final ParticipantDto? participant;

  const ParticipantEditScreen({super.key, required this.drawId, this.participant});

  @override
  State<ParticipantEditScreen> createState() => _ParticipantEditScreenState();
}

class _ParticipantEditScreenState extends State<ParticipantEditScreen> {
  late ParticipantDto item;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    item = widget.participant ?? ParticipantDto.empty(drawId: widget.drawId);
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final token = await UserStorage.getToken();

    dynamic res;
    if (item.id == null) {
      // Створення (Manual Register)
      res = await DRAWS_PARTICIPANTS_REGISTER_MANUAL(token, widget.drawId, item);
    } else {
      // Редагування (Update weight)
      res = await DRAWS_PARTICIPANTS_UPDATE(
          token,
          widget.drawId,
          item.id!,
          item.weightController.text
      );
    }

    if (await CHECK_API(res, context)) {
      MessageModule(context, 'Успішно!', MessageType.success);
      Navigator.pop(context, true);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = item.id != null;

    return TTScaffold(
      title: isEdit ? 'Редагувати вагу' : 'Додати учасника',
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!isEdit) ...[
                CustomInputField(
                  controller: item.userNameController,
                  label: "Ім'я учасника (вручну)",
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: item.contactManualController,
                  label: "Контактні дані",
                ),
                const SizedBox(height: 16),
              ],
              CustomInputField(
                controller: item.weightController,
                label: "Вага (шанси)",
                keyboardType: TextInputType.number,
                // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const Spacer(),
              GlowingButton(
                text: _isLoading ? 'Завантаження...' : 'Зберегти',
                onPressed: _isLoading ? () {} : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}