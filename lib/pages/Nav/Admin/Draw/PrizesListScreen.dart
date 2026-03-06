import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Draw/draws.dart';
import '../../../../api/routs/Draw/prize.dart';
import '../../../../api/routs/Dto/Draw/PrizeDto.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import 'PrizeUploadScreen.dart';

class PrizesListScreen extends StatefulWidget {
  final int drawId;

  const PrizesListScreen({super.key, required this.drawId});

  @override
  State<PrizesListScreen> createState() => _PrizesListScreenState();
}

class _PrizesListScreenState extends State<PrizesListScreen> {
  List<PrizeDto> prizes = [];
  bool isLoading = true;
  Color accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();
    _fetchPrizes();
  }

  Future<void> _fetchPrizes() async {
    setState(() => isLoading = true);
    final token = await UserStorage.getToken();
    final res = await DRAW_PRIZE_LIST(token, widget.drawId);

    if (await CHECK_API(res, context)) {
      final List data = jsonDecode(res.body)['data'];
      setState(() {
        prizes = data.map((e) => PrizeDto.fromJson(e)).toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Призи розіграшу',
      floatingActionButton: GlassFabFloatingButton(
        accentColor: accentColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrizeUploadScreen(drawId: widget.drawId),
            ),
          );
          if (result == true) _fetchPrizes();
        },
      ),
      body: isLoading
          ? const TTLoading()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: prizes.length,
        itemBuilder: (context, index) {
          final prize = prizes[index];
          return _buildPrizeCard(prize);
        },
      ),
    );
  }

  Widget _buildPrizeCard(PrizeDto prize) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PrizeUploadScreen(drawId: widget.drawId, prize: prize),
          ),
        );
        if (result == true) _fetchPrizes();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TTColors.background,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            // Мініатюра зображення
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: prize.images.isNotEmpty
                  ? Image.network(prize.images.first.url, width: 50, height: 50, fit: BoxFit.cover)
                  : Container(width: 50, height: 50, color: Colors.white10, child: const Icon(Icons.card_giftcard)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prize.titleController.text, style: TTTextStyle.title.copyWith(fontSize: 16)),
                  // Text("Кількість: ${prize.quantityController.text} шт.", style: TTTextStyle.subtitle.copyWith(fontSize: 12)),
                ],
              ),
            ),
            if (prize.winnerParticipantId != null)
              const Icon(Icons.emoji_events, color: Colors.amber),
            const Icon(Icons.chevron_right, color: Colors.white30),
          ],
        ),
      ),
    );
  }
}