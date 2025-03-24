import 'package:flutter/material.dart';
import 'package:tt_club_ua/pages/Nav/Admin/Publication/PublicationsScreen.dart';

import '../../components/generalModule.dart';
import '../../components/interface/SearchBarWidgetState.dart';
import '../../components/interface/TileButton.dart';
import '../../config/default.dart';
import 'Admin/Approve/ApproveScreen.dart';
import 'Admin/Publication/CreatePostScreen.dart';
import 'Admin/CreateUserScreen.dart';
import 'Admin/SearchUser.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final TextEditingController _searchController = TextEditingController();

  // void _performSearch() {
  //   String searchText = _searchController.text.trim();
  //   if (searchText.isNotEmpty) {
  //     print("Поиск: $searchText"); // Здесь можно добавить реальный поиск
  //   }
  // }

  void _performSearch() {
    String searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      // Переход на страницу результатов
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchUserScreen(searchQuery: searchText),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(height: 10),
        SearchBarWidget(
          controller: _searchController,
          onSearch: _performSearch,
        ),
        SizedBox(height: 10),
        // Row(
        //   children: [
        //     Spacer(),
        //     ElevatedButton(
        //       onPressed: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(builder: (context) => CreateUserScreen()),
        //         );
        //       },
        //       style: ElevatedButton.styleFrom(
        //           // backgroundColor: Colors.purple,
        //           ),
        //       child: const Text(
        //         'Створити коричтувача',
        //         style: TextStyle(color: Colors.black),
        //       ),
        //     ),
        //     Spacer(),
        //   ],
        // ),
        TileButton(
          icon: Icons.check_circle_outline,
          title: 'Затвердити учасників',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ApproveScreen()), // Переход на экран публикаций
            );
          },
          iconColor: Colors.green,
        ),
        TileButton(
          icon: Icons.article,
          title: 'Публікації',
          // iconColor: COLOR_FIRST_LITE,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PublicationsScreen()), // Переход на экран публикаций
            );
          },
        ),
        TileButton(
          icon: Icons.image,
          title: 'Банер',
          // iconColor: COLOR_FIRST_LITE,
          onTap: () {
            MessageModule(context, 'Скоро буде...', MessageType.information);
          },
        ),
        TileButton(
          icon: Icons.payment_outlined,
          title: 'Оплати',
          // iconColor: COLOR_FIRST_LITE,
          onTap: () {
            MessageModule(context, 'Скоро буде...', MessageType.information);
          },
        ),

        // ElevatedButton(
        //   onPressed: () {
        //     // Navigator.pushReplacementNamed(context, '/user');
        //     // Navigator.pushNamed(context, '/user');
        //     // Navigator.popAndPushNamed(context, '/user');
        //     // Navigator.pushNamedAndRemoveUntil(
        //     //     context, '/user', (route) => true);
        //   },
        //   child: const Text('User'),
        // ),
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
