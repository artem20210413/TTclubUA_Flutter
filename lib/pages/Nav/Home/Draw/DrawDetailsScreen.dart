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
import '../../Admin/Draw/ParticipantsListScreen.dart';
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
  bool _isLoadingChangeStatus = true;
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
    if (await CHECK_API(res, context, isEx: false)) {
      setState(() {
        draw = DrawDto.fromJson(jsonDecode(res.body)['data']);
        _isAdmin = adminStatus;
        isLoading = false;
      });
    } else {
      Navigator.pop(context, true);
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

  Future<void> _changeStatusDraw(DrawStatus status) async {
    setState(() => _isLoadingChangeStatus = true);
    final token = await UserStorage.getToken();
    late DrawDto item = draw ?? DrawDto.empty();
    item.statusController.text = status.value;
    final res = await DRAW_UPLOAD(token, item, null);
    if (await CHECK_API(res, context)) {
      final body = jsonDecode(res.body);
      if (body['data'] != null) {
        setState(() {
          draw = DrawDto.fromJson(body['data']);
        });
      }
      MessageModule(context, status.label + '!', MessageType.success);
    } else {
      MessageModule(context, 'Щось пішло не так', MessageType.error);
    }
    setState(() => _isLoadingChangeStatus = false);
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
                        .map((prize) => _buildPrizeCard(draw, prize))
                        .toList(),

                    const SizedBox(height: 16),

                    // Кнопки дій
                    if (!draw!.isParticipatingNotifier.value &&
                        draw!.getStatus() == DrawStatus.active &&
                        draw!.isPublicNotifier.value)
                      GlowingButton(
                        text: isActionLoading ? "Зачекайте..." : "Брати участь",
                        onPressed: isActionLoading ? () {} : _joinDraw,
                        colorGrowing: accentColor,
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),


                    if (_isAdmin)
                      Column(
                        children: [

                          if (draw!.id != null) ...[
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  side: BorderSide(color: accentColor),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ParticipantsListScreen(draw: draw!),
                                  ),
                                );
                              },
                              child: Text("Учасники (${draw!.participants.length})", style: TextStyle(color: accentColor)),
                            ),
                          ],
                          if (draw!.getStatus() == DrawStatus.planned ||
                              draw!.getStatus() == DrawStatus.finished)
                            GlowingButton(
                              margin: EdgeInsets.only(top: 20),
                              text: "Активувати розіграш",
                              onPressed: () =>
                                  {_changeStatusDraw(DrawStatus.active)},
                              // isLoading: _isLoading,
                            ),
                          if (draw!.getStatus() == DrawStatus.active)
                            GlowingButton(
                              margin: EdgeInsets.only(top: 20),
                              text: "Завершити розіграш",
                              onPressed: () =>
                                  {_changeStatusDraw(DrawStatus.finished)},
                              // isLoading: _isLoading,
                            ),
                        ],
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

  Widget _buildPrizeCard(DrawDto? draw, PrizeDto prize) {
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
        margin: EdgeInsetsGeometry.only(bottom: 16),
        padding: EdgeInsets.only(left: 14, right: 16, top: 10, bottom: 10),
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
            if (_isAdmin &&
                !hasWinner &&
                DrawStatus.active == draw!.getStatus())
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
            if (_isAdmin && hasWinner && DrawStatus.active == draw!.getStatus())
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
