import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Costs/CostsDto.dart';
import '../../../../api/routs/Dto/User/UserSmallDto.dart';
import '../../../../api/routs/costs.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../../components/inputs/BigTextInput.dart';
import '../../../../components/inputs/CustomInputField.dart';
import '../../../../components/inputs/PartnerDatePicker.dart';
import '../../../../components/layout/TTScaffold.dart';

class CostFormScreen extends StatefulWidget {
  final CostsDto? cost; // null = створення нової витрати

  const CostFormScreen({super.key, this.cost});

  @override
  State<CostFormScreen> createState() => _CostFormScreenState();
}

class _CostFormScreenState extends State<CostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late DateTime _date;
  bool _isLoading = false;

  Color accentColor = AccentColorCache.accentColor;

  bool get _isEdit => widget.cost != null;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.cost?.amount ?? '');
    _descriptionController =
        TextEditingController(text: widget.cost?.description ?? '');
    _date = widget.cost?.createdAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final token = await UserStorage.getToken();
    final userId = await UserStorage.getId();

    final dto = CostsDto(
      id: widget.cost?.id ?? 0,
      amount: _amountController.text.trim(),
      description: _descriptionController.text.trim(),
      owner: widget.cost?.owner ??
          UserSmallDto(
            json: const {},
            id: userId ?? 0,
            name: '',
            instagram_nickname: '',
            profileImage: '',
          ),
      createdAt: _date,
    );

    final res = _isEdit
        ? await COSTS_EDIT(token, dto, userId ?? 0)
        : await COSTS_SET(token, dto, userId ?? 0);

    if (!mounted) return;
    final isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      CostsDto? result = dto;
      final body = jsonDecode(res.body);
      if (body['data'] != null) {
        result = CostsDto.fromJson(body['data']);
      }

      if (!mounted) return;
      MessageModule(
        context,
        _isEdit ? 'Витрату оновлено' : 'Витрату створено',
        MessageType.success,
      );

      Navigator.pop(context, result);
      return;
    }

    setState(() => _isLoading = false);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: TTColors.card,
        title: const Text('Видалити витрату?',
            style: TextStyle(color: TTColors.text)),
        content: const Text(
          'Цю дію не можна скасувати.',
          style: TextStyle(color: TTColors.text_secondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Видалити',
                style: TextStyle(color: TTColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || widget.cost == null) return;

    setState(() => _isLoading = true);

    final token = await UserStorage.getToken();
    final res = await COSTS_DELETE(token, widget.cost!.id);

    if (!mounted) return;
    final isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      if (!mounted) return;
      MessageModule(context, 'Витрату видалено', MessageType.success);
      Navigator.pop(context, 'deleted');
      return;
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: _isEdit ? 'Редагування витрати' : 'Нова витрата',
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomInputField(
                  controller: _amountController,
                  label: 'Сума',
                  prefixText: '₴ ',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final v = _amountController.text;
                    if (v == null || v.isEmpty) {
                      return 'Вкажіть суму';
                    }
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Сума має бути більшою за нуль';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BigTextInput(
                  controller: _descriptionController,
                  label: 'Опис',
                  hint: 'На що витрачено кошти',
                  minLines: 3,
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Вкажіть опис витрати';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                PartnerDatePicker(
                  label: 'Дата витрати',
                  value: _date,
                  showTime: false,
                  accentColor: accentColor,
                  onChanged: (d) => setState(() => _date = d ?? _date),
                ),
                const SizedBox(height: 32),
                GlowingButton(
                  text: _isEdit ? 'Зберегти зміни' : 'Створити витрату',
                  colorGrowing: accentColor,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? () {} : _save,
                ),
                if (_isEdit) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: _isLoading ? null : _confirmDelete,
                      icon: const Icon(Icons.delete_outline,
                          color: TTColors.danger, size: 20),
                      label: const Text(
                        'Видалити витрату',
                        style: TextStyle(color: TTColors.danger),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
