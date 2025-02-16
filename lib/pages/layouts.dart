import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/pages/Nav/Home.dart';
import 'package:tt_club_ua/pages/Nav/User.dart';

class Layouts extends StatefulWidget {
  final Widget body;

  const Layouts({required this.body, Key? key}) : super(key: key);

  @override
  State<Layouts> createState() => _LayoutsState();
}

class _LayoutsState extends State<Layouts> {
  String userName = 'unknowns';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 0;

    final List<Widget> _screens = [
      const Home(),
      const User(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
        centerTitle: true,
      ),
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex, // Текущий выбранный индекс
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Обновляем индекс при нажатии
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _loadUser() async {
    final name = await UserStorage.getUserName();

    setState(() {
      userName = name ?? userName;
    });
  }
}
