import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Draw/draws.dart';
import '../../../../api/routs/Draw/participants.dart';
import '../../../../api/routs/Dto/Draw/DrawDto.dart';
import '../../../../api/routs/Dto/Draw/ParticipantDto.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import 'ParticipantEditScreen.dart'; // Екран форми нижче

class ParticipantsListScreen extends StatefulWidget {
  final DrawDto draw;

  const ParticipantsListScreen({super.key, required this.draw});

  @override
  State<ParticipantsListScreen> createState() => _ParticipantsListScreenState();
}

class _ParticipantsListScreenState extends State<ParticipantsListScreen> {
  List<ParticipantDto> participants = [];
  bool isLoading = true;
  Color accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  Future<void> _fetchParticipants() async {
    setState(() => isLoading = true);
    final token = await UserStorage.getToken();
    final res = await DRAW_PARTICIPANTS_LIST(token, widget.draw);

    if (await CHECK_API(res, context)) {
      final List data = jsonDecode(res.body)['data'];
      setState(() {
        participants = data.map((e) => ParticipantDto.fromJson(e)).toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Учасники',
      floatingActionButton: GlassFabFloatingButton(
        accentColor: accentColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ParticipantEditScreen(drawId: widget.draw.id!),
            ),
          );
          if (result == true) _fetchParticipants();
        },
      ),
      body: isLoading
          ? const TTLoading()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: participants.length,
        itemBuilder: (context, index) {
          final person = participants[index];
          return _buildParticipantCard(person);
        },
      ),
    );
  }

  Widget _buildParticipantCard(ParticipantDto person) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ParticipantEditScreen(
              drawId: widget.draw.id!,
              participant: person,
            ),
          ),
        );
        if (result == true) _fetchParticipants();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TTColors.background,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: person.isWinner ? accentColor : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: person.profileImage != null
                  ? NetworkImage(person.profileImage!)
                  : null,
              child: person.profileImage == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.userNameController.text.isEmpty
                        ? "ID: ${person.id}"
                        : person.userNameController.text,
                    style: TTTextStyle.title.copyWith(fontSize: 16),
                  ),
                  Text(
                    person.contactManualController.text,
                    style: TTTextStyle.subtitle.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text("Вага", style: TextStyle(color: accentColor, fontSize: 10)),
                Text(
                  person.weightController.text,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}