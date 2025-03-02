import 'package:flutter/material.dart';

import '../../components/form/SearchBarWidgetState.dart';
import 'Admin/CreateCarScreen.dart';
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
        SizedBox(height: 50),
        Row(
          children: [
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateUserScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                  // backgroundColor: Color(0xFF8B0000),
                  ),
              child: const Text(
                'Створити коричтувача',
                style: TextStyle(color: Colors.black),
              ),
            ),
            Spacer(),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => CreateCarScreen()),
            //     );
            //   },
            //   style: ElevatedButton.styleFrom(
            //       // backgroundColor: Color(0xFF8B0000),
            //       ),
            //   child: const Text(
            //     '+ Авто',
            //     style: TextStyle(color: Colors.black),
            //   ),
            // ),
            // Spacer(),
          ],
        )

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
