import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tt_club_ua/api/routs/Draw/draws.dart';
import 'package:tt_club_ua/config/default.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Draw/DrawStatus.dart';
import '../../../../api/routs/Dto/Draw/DrawDto.dart';
import '../../../../api/routs/Dto/Draw/PrizeDto.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../../components/labels/TTLabel.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/viewers/ImagesCarousel.dart';
import '../../Admin/Draw/DrawUploadScreen.dart';

class DrawDetailsScreen extends StatefulWidget {
  final DrawDto drawDto;

  const DrawDetailsScreen({super.key, required this.drawDto});

  @override
  State<DrawDetailsScreen> createState() => _DrawDetailsScreenState();
}

class _DrawDetailsScreenState extends State<DrawDetailsScreen> {
  DrawDto? draw;
  bool isLoading = true;
  bool isActionLoading = false;
  bool _isAdmin = false;
  Color accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await UserStorage.getToken();
    final adminStatus = await UserStorage.isAdmin();

    // Припускаємо метод DRAWS_GET(token, id)
    final res = await DRAW_SHOW(token, widget.drawDto.id!);

    if (await CHECK_API(res, context)) {
      setState(() {
        draw = DrawDto.fromJson(jsonDecode(res.body)['data']);
        _isAdmin = adminStatus;
        isLoading = false;
      });
    }
  }

  // Логіка участі
  Future<void> _joinDraw() async {
    setState(() => isActionLoading = true);
    // final token = await UserStorage.getToken();
    // final res = await DRAWS_PARTICIPATE(token, draw!.id!);
    //
    // if (await CHECK_API(res, context)) {
    //   MessageModule(context, "Ви успішно зареєстровані!", MessageType.success);
    //   _loadData();
    // }
    setState(() => isActionLoading = false);
  }

  // Логіка перегравання (тільки адмін)
  Future<void> _reRollDraw() async {
    // final token = await UserStorage.getToken();
    // final res = await DRAWS_REROLL(token, draw!.id!); // Твій API метод для рандому
    //
    // if (await CHECK_API(res, context)) {
    //   MessageModule(context, "Результати оновлено!", MessageType.success);
    //   _loadData();
    // }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return const TTScaffold(title: 'Розіграш', body: TTLoading());

    return TTScaffold(
      title: draw!.titleController.text,
      // Кругла кнопка редагування для адміна
      floatingActionButton: _isAdmin
          ? GlassFabFloatingButton(
              iconPath: 'assets/svg/pencil.svg',
              accentColor: accentColor,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DrawUploadScreen(draw: draw)),
                );
                if (result != null) _loadData();
              },
            )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 8),
        child: TTNeumorphicBox(
          padding: EdgeInsets.only(top: 12, bottom: 24, left: 8, right: 14),
          // radius: 32,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                if (draw!.images.isNotEmpty)
                  ImagesCarousel(
                    images: draw!.images,
                    height: 320,
                    borderRadius: 32,
                  ),

                if (draw!.images.isNotEmpty) const SizedBox(height: 16),
// Використовуємо Align або інший спосіб притиснути до правого краю,
// бо Spacer() не працює всередині Wrap
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    // Вирівнювання елементів по правому краю
                    spacing: 8.0,
                    // Відступ між лейблами по горизонталі
                    runSpacing: 8.0,
                    // Відступ між рядками по вертикалі
                    children: [
                      TTLabel(
                          text: draw!.getStatus().label,
                          accentColor: draw!.getStatus().color),
                      if (draw!.isParticipatingNotifier.value)
                        TTLabel(
                            text: "Зареєстровано",
                            accentColor: DrawStatus.active == draw!.getStatus()
                                ? TTColors.success
                                : TTColors.text_secondary),
                      if (draw!.allowMultipleWinsNotifier.value)
                        TTLabel(
                          text: "Мульти-виграш",
                          accentColor: accentColor,
                        ),
                      if (draw!.isPublicNotifier.value)
                        TTLabel(text: "Публічний", accentColor: accentColor),
                    ],
                  ),
                ),
                if (draw!.registrationUntil != null)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('Дійсний до: ', style: TTTextStyle.subtitle),
                          const SizedBox(width: 6),
                          Text(
                              DateFormat('dd.MM.yyyy HH:mm')
                                  .format(draw!.registrationUntil!),
                              style: TTTextStyle.subtitle
                                  .copyWith(color: TTColors.text)),
                        ],
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(draw!.descriptionController.text,
                        style: TTTextStyle.subtitle),
                    const SizedBox(height: 16),

                    Text("Призи:",
                        style: TTTextStyle.title.copyWith(fontSize: 18)),
                    const SizedBox(height: 12),

                    // Список карток призів
                    ...draw!.prizes
                        .map((prize) => _buildPrizeCard(prize))
                        .toList(),

                    const SizedBox(height: 40),

                    // Кнопки дій
                    if (!draw!.isParticipatingNotifier.value && draw!.getStatus() == DrawStatus.active && draw!.isPublicNotifier.value)
                      GlowingButton(
                        text: isActionLoading ? "Зачекайте..." : "Брати участь",
                        onPressed: isActionLoading ? () {} : _joinDraw,
                        colorGrowing: accentColor,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                      ),

                    if (_isAdmin)
                      GlowingButton(
                        text: "ПЕРЕГРАТИ ПРИЗ",
                        onPressed: _reRollDraw,
                        // isLoading: _isLoading,
                      ),

                    if (_isAdmin)
                      GlowingButton(
                        text: "Розіграти ПРИЗ",
                        onPressed: _reRollDraw,
                        // isLoading: _isLoading,
                      ),

                    if (_isAdmin)
                      GlowingButton(
                        text: "Активувати розіграш",
                        onPressed: () => {},
                        // isLoading: _isLoading,
                      ),
                    if (_isAdmin)
                      GlowingButton(
                        text: "Скасувати розіграш",
                        onPressed: () => {},
                        // isLoading: _isLoading,
                      ),
                    if (_isAdmin)
                      GlowingButton(
                        text: "Перевести у запланований",
                        onPressed: () => {},
                        // isLoading: _isLoading,
                      ),
                    if (_isAdmin)
                      GlowingButton(
                        text: "Видалити",
                        onPressed: () => {},
                        // isLoading: _isLoading,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrizeCard(PrizeDto prize) {
    bool hasWinner = prize.winnerParticipantId != null;

    return GestureDetector(
      onTap: (_isAdmin && hasWinner)
          ? () {
              /* Navigator.push до сторінки учасника */
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: hasWinner ? accentColor.withOpacity(0.5) : Colors.white10),
        ),
        child: Row(
          children: [
            // Фото призу
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: prize.images.isNotEmpty
                  ? Image.network(prize.images.first.url,
                      width: 60, height: 60, fit: BoxFit.cover)
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.white10,
                      child: const Icon(Icons.card_giftcard)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prize.titleController.text,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),

                  if (hasWinner)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text("Переможець: ID ${prize.winnerParticipantId}",
                          style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    )
                  else
                    const Text("Очікує розіграшу",
                        style: TextStyle(color: Colors.white30, fontSize: 12)),
                ],
              ),
            ),
            if (_isAdmin && hasWinner)
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.white24),
          ],
        ),
      ),
    );
  }

}
