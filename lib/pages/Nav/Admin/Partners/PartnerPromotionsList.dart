import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Partners/PartnerDto.dart';
import '../../../../api/routs/Dto/Partners/PromotionDto.dart';
import '../../../../api/routs/Partners/promotions.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/viewers/ConfirmAndRun.dart';
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
  Color accentColor = AccentColorCache.accentColor;
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

  Future<void> onDeletePromotion(PromotionDto promo) async {

    final token = await UserStorage.getToken();
    final res = await PARTNERS_PROMOTIONS_DESTROY(token, promo);

    if (await CHECK_API(res, context)) {
      setState(() {
        // Видаляємо зі списку локально
        _promotions.removeWhere((element) => element.id == promo.id);
      });

      MessageModule(context, 'Акцію успішно видалено', MessageType.success);
    } else {
      print(jsonDecode(res.body));
      MessageModule(context, 'Помилка при видаленні', MessageType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: widget.partner.titleController.text,
      floatingActionButton: GlassFabFloatingButton(
        accentColor: accentColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PromotionUploadScreen(
                partner: widget.partner,
              ),
            ),
          );
          if (result != null) _fetchPromotions();
        },
        // onPressed: _onSearch,       // Передаєте функцію оновлення
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Основна частина зі списком або завантаженням
              Expanded(
                child: _isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFFE5B80B)))
                    : _promotions.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            // Прибираємо shrinkWrap: true, бо Expanded сам контролює розмір
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: _promotions.length,
                            itemBuilder: (context, index) {
                              final promo = _promotions[index];
                              return PromotionAdminCard(
                                promotion: promo,
                                onEdit: () => onAdd(promo),
                                // onDelete: () => onDeletePromotion(promo),
                                onDelete: () =>
                                    ConfirmAndRun(
                                      context: context,
                                      dialogTitle: "Видалити акцію?",
                                      dialogMessage:
                                      "Ви впевнені, що хочете видалити акцію '${promo.titleController.text}'? Цю дію неможливо скасувати.",
                                      buttonClose: Text('Скасувати',
                                          style: TTTextStyle.subtitle),
                                      buttonSuccess: Text('Видалити',
                                          style: TTTextStyle.subtitle.copyWith(color: TTColors.text)),
                                      action: () => onDeletePromotion(promo),
                                    ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Виніс пустий стан в окремий метод для чистоти коду
  Widget _buildEmptyState() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.percent, size: 40, color: Colors.white24),
            const SizedBox(height: 12),
            Text(
              "У цього партнера ще немає акцій",
              style: TTTextStyle.subtitle.copyWith(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}
