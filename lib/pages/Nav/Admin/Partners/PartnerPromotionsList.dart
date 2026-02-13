import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Partners/PartnerDto.dart';
import '../../../../api/routs/Dto/Partners/PromotionDto.dart';
import '../../../../api/routs/Partners/promotions.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../config/default.dart';
import 'PromotionAdminCard.dart';
import 'PromotionUploadScreen.dart';

class PartnerPromotionsList extends StatefulWidget {
  final PartnerDto partner;

  const PartnerPromotionsList({
    super.key,
    required this.partner,
  });

  @override
  State<PartnerPromotionsList> createState() => _PartnerPromotionsListState();
}

class _PartnerPromotionsListState extends State<PartnerPromotionsList> {
  late List<PromotionDto> _promotions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
  }

  Future<void> _fetchPromotions() async {
    final token = await UserStorage.getToken();

    final res = await PARTNERS_PROMOTIONS_LIST(token, widget.partner);

    final isSuccess = await CHECK_API(res, context);
    if (!isSuccess) {
      setState(() => _isLoading = false);
      return;
    }

    final data = jsonDecode(res.body)['data'] as List;
    final newItems = data.map((e) => PromotionDto.fromJson(e)).toList();

    if (mounted) {
      setState(() {
        _promotions = newItems;
        _isLoading = false;
      });
    }
  }

  Future<void> onAdd(promo) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PromotionUploadScreen(
          partner: widget.partner,
          promotion: promo,
        ),
      ),
    );

    // Оновлюємо локальний об'єкт у списку після повернення
    if (result != null) {
      _fetchPromotions();
    }
  }

  void onDeletePromotion(PromotionDto promo) async {
    // 1. Показуємо діалог підтвердження
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TTColors.background,
        title: const Text("Видалити акцію?",
            style: TextStyle(color: Colors.white)),
        content: Text(
          "Ви впевнені, що хочете видалити акцію '${promo.titleController.text}'? Цю дію неможливо скасувати.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Скасувати",
                style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Видалити",
                style: TextStyle(color: TTColors.danger)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 2. Виконуємо видалення
    final token = await UserStorage.getToken();
    final res = await partners_promotions_destroy(token, promo);

    if (await CHECK_API(res, context)) {
      setState(() {
        // Видаляємо зі списку локально
        _promotions.removeWhere((element) => element.id == promo.id);
      });

      MessageModule(context, 'Акцію успішно видалено', MessageType.success);
    } else {
      MessageModule(context, 'Помилка при видаленні', MessageType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: widget.partner.titleController.text,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок секції з кнопкою "Додати"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Акції партнера (${_promotions.length})",
                style: TTTextStyle.title.copyWith(fontSize: 18),
              ),
              TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PromotionUploadScreen(
                        partner: widget.partner,
                      ),
                    ),
                  );

                  // Якщо акцію успішно створено, оновлюємо список
                  if (result != null) {
                    _fetchPromotions();
                  }
                },
                icon: const Icon(Icons.add, color: Color(0xFFE5B80B), size: 18),
                label: const Text(
                  "Додати",
                  style: TextStyle(color: Color(0xFFE5B80B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Перевірка на порожній список
          if (_promotions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Icon(Icons.percent, size: 40, color: Colors.white24),
                  const SizedBox(height: 12),
                  Text(
                    "У цього партнера ще немає акцій",
                    style: TTTextStyle.subtitle.copyWith(color: Colors.white38),
                  ),
                ],
              ),
            )
          else
            // Сам список акцій
            ListView.builder(
              shrinkWrap: true,
              // Важливо, якщо список всередині SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _promotions.length,
              itemBuilder: (context, index) {
                final promo = _promotions[index];
                return PromotionAdminCard(
                  promotion: promo,
                  onEdit: () => {onAdd(promo)}, //promo
                  onDelete: () => {onDeletePromotion(promo)},
                );
              },
            ),
        ],
      ),
    );
  }
}
