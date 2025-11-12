import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/pages/Nav/Admin/Publication/PublicationsScreen.dart';

import '../../Storage/UserStorage.dart';
import '../../api/routs/registaion.dart';
import '../../api/routs/root.dart';
import '../../components/generalModule.dart';
import '../../components/interface/SearchBarWidgetState.dart';
import '../../components/interface/TileButton.dart';
import '../../config/default.dart';
import 'Admin/Approve/ApproveScreen.dart';
import 'Admin/Costs/CostsListScreen.dart';
import 'Admin/Publication/CreatePostScreen.dart';
import 'Admin/User/SearchUser.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Center(
          child: Text(
            'Не все зразу...',
            style: TTTextStyle.title,
          ),
        )
      ],
    );
  }
//
// void _onSearch() {
//   String searchText = _controller.text.trim();
//   if (searchText.isNotEmpty) {
//     print("Поиск: $searchText"); // Тут можно заменить на свой обработчик
//   }
// }
}
