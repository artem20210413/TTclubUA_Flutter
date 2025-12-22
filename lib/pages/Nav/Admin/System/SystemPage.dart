import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/pages/Nav/Admin/Event/EventsScreen.dart';
import 'package:tt_club_ua/pages/Nav/Admin/Merch/MerchScreen.dart';
import 'package:tt_club_ua/pages/Nav/Admin/Publication/PublicationsScreen.dart';

import '../../../../components/interface/TileButton.dart';
import '../../../../components/layout/TTScaffold.dart';
import 'SystemUserStatsScreen.dart';

class SystemPage extends StatefulWidget {
  const SystemPage({super.key});

  @override
  State<SystemPage> createState() => _SystemPageState();
}

class _SystemPageState extends State<SystemPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Статистика',
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 10),
            TileButton(
              icon: Icons.groups,
              title: 'Про учасників',
              iconColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SystemUserStatsScreen(),
                  ), // Переход на экран публикаций
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
