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
import '../../../../components/viewers/ConfirmAndRun.dart';
import '../../../../config/default.dart';
import '../../Mention/Profile.dart';

class ParticipantEditScreen extends StatefulWidget {
  final int drawId;
  final ParticipantDto? participant;

  const ParticipantEditScreen(
      {super.key, required this.drawId, this.participant});

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

    dynamic res = item.id == null
        ? await DRAWS_PARTICIPANTS_REGISTER_MANUAL(token, widget.drawId, item)
        : await DRAWS_PARTICIPANTS_UPDATE(token, widget.drawId, item.id!, item);

    if (await CHECK_API(res, context)) {
      MessageModule(context, 'Успішно!', MessageType.success);
      Navigator.pop(context, true);
      return;
    } else {
      MessageModule(context, 'Щось пішло не так', MessageType.error);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteParticipant() async {
    final token = await UserStorage.getToken();
    final res = await DRAWS_PARTICIPANTS_DELATE(token, widget.drawId, item.id!);
    if (await CHECK_API(res, context)) {
      MessageModule(context, 'Учасник видален!', MessageType.success);
      Navigator.pop(context, true);
    } else {
      MessageModule(context, 'Щось пішло не так..', MessageType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isNew = item.id == null;
    bool isCustom = item.userId == null;

    return TTScaffold(
      title: !isNew ? 'Редагувати вагу' : 'Додати учасника',
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!isCustom) ...[
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profile(id: item.userId),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: item.profileImage != null
                            ? NetworkImage(item.profileImage!)
                            : null,
                        child: item.profileImage == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "#${item.id} ${item.userNameController.text}",
                          style: TTTextStyle.title.copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],
              if (isCustom) ...[
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
              const SizedBox(height: 32),
              GlowingButton(
                text: _isLoading ? 'Завантаження...' : 'Зберегти',
                onPressed: _isLoading ? () {} : _save,
              ),
              if (!isNew)
                Padding(
                  padding: const EdgeInsets.only(top: 34, bottom: 16),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        ConfirmAndRun(
                          context: context,
                          dialogTitle: 'Виключити учасника?',
                          dialogMessage:
                              'Ви впевнені, що хочете видалити ${item.userNameController.text} зі списку учасників? Цю дію неможливо скасувати.',
                          action:
                              _deleteParticipant, // Твій метод видалення учасника
                        );
                      },
                      child: Text(
                        'Видалити учасника',
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
