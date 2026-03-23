import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/Draw/participants.dart';
import '../../../../api/routs/Dto/Draw/DrawDto.dart';
import '../../../../api/routs/Dto/Draw/ParticipantDto.dart';
import '../../../../api/routs/root.dart';
import '../../../../components/TTLoading.dart';
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
  final ScrollController _scrollController =
      ScrollController(); // Контролер прокрутки
  List<ParticipantDto> participants = [];

  bool isLoading = true; // Перше завантаження
  bool isLoadMore = false; // Завантаження наступної сторінки
  bool hasMore = true; // Чи є ще дані в API
  int currentPage = 1; // Поточна сторінка

  Color accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();
    _fetchParticipants();

    // Слухаємо прокрутку
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!isLoadMore && hasMore && !isLoading) {
          _fetchMore();
        }
      }
    });
  }

  // Перше завантаження (або оновлення)
  Future<void> _fetchParticipants() async {
    setState(() {
      isLoading = true;
      currentPage = 1;
      hasMore = true;
    });

    final token = await UserStorage.getToken();
    final res = await DRAW_PARTICIPANTS_LIST(token, widget.draw, page: 1);

    if (await CHECK_API(res, context)) {
      final List data = jsonDecode(res.body)['data'];
      setState(() {
        participants = data.map((e) => ParticipantDto.fromJson(e)).toList();
        hasMore = data.length >=
            15; // Якщо прийшло менше 15 (або твій limit), значить сторінок більше нема
        isLoading = false;
      });
    }
  }

  // Завантаження наступних сторінок
  Future<void> _fetchMore() async {
    setState(() => isLoadMore = true);
    currentPage++;

    final token = await UserStorage.getToken();
    final res =
        await DRAW_PARTICIPANTS_LIST(token, widget.draw, page: currentPage);

    if (await CHECK_API(res, context)) {
      final List data = jsonDecode(res.body)['data'];
      final nextItems = data.map((e) => ParticipantDto.fromJson(e)).toList();

      setState(() {
        participants.addAll(nextItems);
        hasMore = nextItems.isNotEmpty;
        isLoadMore = false;
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
          : RefreshIndicator(
              onRefresh: _fetchParticipants,
              child: ListView.builder(
                controller: _scrollController, // Прив'язуємо контролер
                padding: const EdgeInsets.all(16),
                itemCount: participants.length + (isLoadMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == participants.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final person = participants[index];
                  return _buildParticipantCard(person);
                },
              ),
            ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Обов'язково чистимо контролер
    super.dispose();
  }

// class ParticipantsListScreen extends StatefulWidget {
//   final DrawDto draw;
//
//   const ParticipantsListScreen({super.key, required this.draw});
//
//   @override
//   State<ParticipantsListScreen> createState() => _ParticipantsListScreenState();
// }
//
// class _ParticipantsListScreenState extends State<ParticipantsListScreen> {
//   List<ParticipantDto> participants = [];
//   bool isLoading = true;
//   Color accentColor = AccentColorCache.accentColor;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchParticipants();
//   }
//
//   Future<void> _fetchParticipants() async {
//     setState(() => isLoading = true);
//     final token = await UserStorage.getToken();
//     final res = await DRAW_PARTICIPANTS_LIST(token, widget.draw);
//
//     if (await CHECK_API(res, context)) {
//       final List data = jsonDecode(res.body)['data'];
//       setState(() {
//         participants = data.map((e) => ParticipantDto.fromJson(e)).toList();
//         isLoading = false;
//       });
//     }
//   }

  // @override
  // Widget build(BuildContext context) {
  //   return TTScaffold(
  //     title: 'Учасники',
  //     floatingActionButton: GlassFabFloatingButton(
  //       accentColor: accentColor,
  //       onPressed: () async {
  //         final result = await Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (_) => ParticipantEditScreen(drawId: widget.draw.id!),
  //           ),
  //         );
  //         if (result == true) _fetchParticipants();
  //       },
  //     ),
  //     body: isLoading
  //         ? const TTLoading()
  //         : ListView.builder(
  //             padding: const EdgeInsets.all(16),
  //             itemCount: participants.length,
  //             itemBuilder: (context, index) {
  //               final person = participants[index];
  //               return _buildParticipantCard(person);
  //             },
  //           ),
  //   );
  // }

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
            color: person.isWinner ? TTColors.success : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: person.profileImage != null
                  ? NetworkImage(person.profileImage!)
                  : null,
              child:
                  person.profileImage == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "#${person.id} ${person.userNameController.text}",
                    style: TTTextStyle.title.copyWith(fontSize: 16),
                  ),
                  Text(
                    person.contactManualController.text,
                    style: TTTextStyle.subtitle.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
