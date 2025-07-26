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

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final TextEditingController _searchController = TextEditingController();
  var countRegistration = 0;

  // void _performSearch() {
  //   String searchText = _searchController.text.trim();
  //   if (searchText.isNotEmpty) {
  //     print("Поиск: $searchText"); // Здесь можно добавить реальный поиск
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _loadRegistration();
  }

  void _loadRegistration() async {
    final token = await UserStorage.getToken();
    final res = await REGISTRATION_COUNT(token);

    bool isSuccess = await CHECK_API(res, context);

    if (isSuccess) {
      setState(() {
        countRegistration = jsonDecode(res.body)['data']['count'] ?? 0;
      });
    } else {
      MessageModule(
          context, 'Затвердженя не туспішно отримано', MessageType.error);
    }
  }

  void _performSearch() {
    String searchText = _searchController.text.trim();
    // if (searchText.isNotEmpty) {
    // Переход на страницу результатов
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchUserScreen(searchQuery: searchText),
      ),
    );
    // }
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
            newCount: countRegistration),
        TileButton(
          icon: Icons.payment_outlined,
          title: 'Витрати',
          // iconColor: COLOR_FIRST_LITE,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CostsListScreen()), // Переход на экран публикаций
            );
          },
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
          icon: Icons.download_sharp,
          title: 'Завантажте всіх учасників в Excel',
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
