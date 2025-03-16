import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/CustomAppBar.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/pages/Nav/Home.dart';
import 'package:tt_club_ua/pages/Nav/Admin.dart';
import 'package:tt_club_ua/pages/Nav/Mention.dart';
import 'package:tt_club_ua/pages/Nav/User.dart';

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> {
  String userName = 'unknowns';
  int _currentIndex = 0;
  bool _isAdmin = false; // Значение по умолчанию
  bool _isLoading = true; // Loading state
  List<Widget> _screens = [];
  List<BottomNavigationBarItem> _screensItems = [];

  // final List<Widget> _screens = [
  //   const Home(),
  //   const Admin(),
  //   const User(),
  // ];

  @override
  void initState() {
    super.initState();

    _loadUser();
    // _fetchScreens();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(body: CenterLoadingModule)
        : Scaffold(
            appBar: CustomAppBar(userName),
            // AppBar(
            //       title: Text(userName),
            //       centerTitle: true,
            //     ),
            body: _screens[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.white,
              currentIndex: _currentIndex,
              // Текущий выбранный индекс
              onTap: (index) {
                setState(() {
                  _currentIndex = index; // Обновляем индекс при нажатии
                });
              },
              items: _screensItems,
            ),
          );
  }

  Future<void> _loadUser() async {
    final name = await UserStorage.getUserName();
    final isAdmin = await UserStorage.whereInRole([UserRole.admin]);

    setState(() {
      userName = name ?? userName;
      _isAdmin = isAdmin ?? _isAdmin;
      _isLoading = false;
    });

    _fetchScreens();
  }

  void _fetchScreens() {
    setState(() {
      _screens = [
        const Home(),
        const Mention(),
        if (_isAdmin) const Admin(),
        const User(),
      ];

      _screensItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Головна',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Пошук авто',
        ),
        if (_isAdmin)
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.admin_panel_settings,
              // color: Colors.lightBlueAccent,
            ),
            label: 'Адмін',
          ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Профіль',
        ),
      ];
    });
  }
}
