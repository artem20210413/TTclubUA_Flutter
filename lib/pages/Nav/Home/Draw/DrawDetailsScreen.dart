import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tt_club_ua/api/routs/Draw/draws.dart';
import 'package:tt_club_ua/config/default.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Dto/Draw/DrawDto.dart';
import '../../../../api/routs/Dto/Draw/PrizeDto.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/generalModule.dart';
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
    if (isLoading) return const TTScaffold(title: 'Розіграш', body: TTLoading());

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
            MaterialPageRoute(builder: (_) => const DrawUploadScreen()),
          );
          if (result != null) _loadData();
        },
      )
          : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Головне зображення
            if (draw!.images.isNotEmpty)
              Image.network(draw!.images.first.url, width: double.infinity, height: 250, fit: BoxFit.cover),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(draw!.titleController.text, style: TTTextStyle.title.copyWith(fontSize: 24)),
                  const SizedBox(height: 10),
                  Text(draw!.descriptionController.text, style: TTTextStyle.subtitle),
                  const SizedBox(height: 25),

                  Text("Призи:", style: TTTextStyle.title.copyWith(fontSize: 18)),
                  const SizedBox(height: 12),

                  // Список карток призів
                  ...draw!.prizes.map((prize) => _buildPrizeCard(prize)).toList(),

                  const SizedBox(height: 40),

                  // Кнопки дій
                  if (!_isAdmin && !draw!.isParticipatingNotifier.value)
                    GlowingButton(
                      text: isActionLoading ? "Зачекайте..." : "Брати участь",
                      onPressed: isActionLoading ? () {} : _joinDraw,
                    ),

                  if (_isAdmin)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: Colors.redAccent),
                        ),
                        onPressed: _reRollDraw,
                        child: const Text("ПЕРЕГРАТИ РОЗІГРАШ", style: TextStyle(color: Colors.redAccent)),
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizeCard(PrizeDto prize) {
    bool hasWinner = prize.winnerParticipantId != null;

    return GestureDetector(
      onTap: (_isAdmin && hasWinner)
          ? () { /* Navigator.push до сторінки учасника */ }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: hasWinner ? accentColor.withOpacity(0.5) : Colors.white10),
        ),
        child: Row(
          children: [
            // Фото призу
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: prize.images.isNotEmpty
                  ? Image.network(prize.images.first.url, width: 60, height: 60, fit: BoxFit.cover)
                  : Container(width: 60, height: 60, color: Colors.white10, child: const Icon(Icons.card_giftcard)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prize.titleController.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("Кількість: ${prize.quantityController.text}", style: const TextStyle(color: Colors.white60, fontSize: 12)),

                  if (hasWinner)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                          "Переможець: ID ${prize.winnerParticipantId}",
                          style: TextStyle(color: accentColor, fontWeight: FontWeight.w600, fontSize: 13)
                      ),
                    )
                  else
                    const Text("Очікує розіграшу", style: TextStyle(color: Colors.white30, fontSize: 12)),
                ],
              ),
            ),
            if (_isAdmin && hasWinner) const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}