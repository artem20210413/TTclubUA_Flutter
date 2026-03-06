import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tt_club_ua/api/routs/Draw/draws.dart';
import 'package:tt_club_ua/config/default.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Draw/DrawStatus.dart';
import '../../../../api/routs/Draw/participants.dart';
import '../../../../api/routs/Dto/Draw/DrawDto.dart';
import '../../../../api/routs/Dto/Draw/PrizeDto.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/buttons/CircleButton.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../../components/labels/TTLabel.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/viewers/ConfirmAndRun.dart';
import '../../../../components/viewers/ImagesCarousel.dart';
import '../../../../components/viewers/LittleImageThumbnail.dart';
import '../../Admin/Draw/DrawUploadScreen.dart';
import '../../Mention/Profile.dart';

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
    final token = await UserStorage.getToken();
    final res = await DRAWS_PARTICIPANTS_REGISTER(token, draw!.id!);

    if (await CHECK_API(res, context)) {
      MessageModule(context, "Ви успішно зареєстровані!", MessageType.success);
      _loadData();
    }
    setState(() => isActionLoading = false);
  }

  // Логіка перегравання (тільки адмін)
  Future<void> _RollDraw(PrizeDto prize) async {
    final token = await UserStorage.getToken();
    final res = await DRAW_ROLL(token, draw!.id!, prize.id!);

    if (await CHECK_API(res, context)) {
      MessageModule(context, "Переможця визначено!", MessageType.success);
      _loadData();
    }
  }

  // Логіка перегравання (тільки адмін)
  Future<void> _reRollDraw(PrizeDto prize) async {
    final token = await UserStorage.getToken();
    final res = await DRAW_RESET(token, draw!.id!, prize.id!);

    if (await CHECK_API(res, context)) {
      MessageModule(context, "Результати скасовано!", MessageType.success);
      _loadData();
    }
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
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Дійсний до: ', style: TTTextStyle.subtitle),
                        const SizedBox(width: 6),
                        Text(
                            draw!.registrationUntil != null
                                ? DateFormat('dd.MM.yyyy HH:mm')
                                    .format(draw!.registrationUntil!)
                                : '-',
                            style: TTTextStyle.subtitle
                                .copyWith(color: TTColors.text)),
                        const Spacer(),
                        Text("Учасників: ", style: TTTextStyle.subtitle),
                        const SizedBox(width: 6),
                        Text(draw!.participants.length.toString(),
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
                    if (!draw!.isParticipatingNotifier.value &&
                        draw!.getStatus() == DrawStatus.active &&
                        draw!.isPublicNotifier.value)
                      GlowingButton(
                        text: isActionLoading ? "Зачекайте..." : "Брати участь",
                        onPressed: isActionLoading ? () {} : _joinDraw,
                        colorGrowing: accentColor,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                      ),

                    const SizedBox(height: 40),
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
      onTap: (hasWinner && prize.winner!.userId != null)
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(id: prize.winner!.userId),
                ),
              );
            }
          : null,
      child: TTNeumorphicBox(
        padding: EdgeInsets.only(left: 14, right: 16),
        radius: 12,
        child: Row(
          children: [
            if (prize!.images.isNotEmpty)
              LittleImageThumbnail(
                images: prize.images, // Передаем весь список List<ImageUrlDto>
                size: 60,
                radius: 12,
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
                      child: Text(
                          "Переможець: ${prize.winner!.userNameController.text}",
                          style: TTTextStyle.subtitle
                              .copyWith(color: TTColors.text)),
                    )
                  else
                    const Text("Очікує розіграшу",
                        style: TextStyle(color: Colors.white30, fontSize: 12)),
                ],
              ),
            ),
            if (_isAdmin && !hasWinner)
              CircleButton(
                accentColor: accentColor,
                iconAsset: 'assets/svg/dice.svg',
                sizeIcon: 40,
                // isLoading: _isLoading,
                onTap: () => ConfirmAndRun(
                  context: context,
                  dialogTitle: 'Провести розіграш?',
                  dialogMessage:
                      'Ви готові обрати щасливчика, який отримає ${prize.titleController.text}?',
                  action: () => _RollDraw(prize),
                ),
              ),
            if (_isAdmin && hasWinner)
              CircleButton(
                accentColor: accentColor,
                // iconAsset: 'assets/svg/arrow-counter-clockwise.svg',
                iconAsset: 'assets/svg/trash.svg',
                // sizeIcon: 40,
                // isLoading: _isLoading,
                onTap: () => ConfirmAndRun(
                  context: context,
                  dialogTitle: 'Скасувати результат?',
                  dialogMessage:
                      'Ви впевнені, що хочете обрати нового переможця для призу "${prize.titleController.text}"? Поточний результат буде видалено.',
                  action: () => _reRollDraw(prize),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
