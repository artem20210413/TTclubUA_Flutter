import 'dart:io';
import 'dart:ui';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/generalModule.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/pages/Nav/Home.dart';
import 'package:tt_club_ua/pages/Nav/Admin.dart';
import 'package:tt_club_ua/pages/Nav/Mention.dart';
import 'package:tt_club_ua/pages/Nav/User.dart';

import '../Storage/Cache/DeviceInsetsCache.dart';
import '../components/buttons/NavCircleButton.dart';
import 'Nav/Calendar.dart';

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => NavState();
}

class NavState extends State<Nav> {
  int _currentIndex = 0;
  bool _isAdmin = false; // Значение по умолчанию
  bool _isLoading = true; // Loading state
  List<Widget> _screens = [];
  final isIOS = Platform.isIOS;
  List<String> _navSvgs = [];

  @override
  void initState() {
    super.initState();

    _loadUser();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DeviceInsetsCache.init(context);
  }
  void setTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(body: CenterLoadingModule)
        : GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: isIOS ? true : false,
              child: Scaffold(
                backgroundColor: TTColors.background,
                extendBody: true,
                // appBar: AppBar(
                //   toolbarHeight: 20,
                //   backgroundColor: Colors.transparent,
                //   surfaceTintColor: Colors.transparent,
                // ),
                body: _screens[_currentIndex],

                // ADD: центральная кнопка под вырез
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: SizedBox(
                  width: 64, height: 64,
                  // child: FloatingActionButton(
                  //   elevation: 0,
                  //   onPressed: () {},
                  //   child: const Icon(Icons.add, size: 28),
                  // ),
                ),

                bottomNavigationBar: AnimatedBottomNavigationBar.builder(
                  itemCount: _navSvgs.length,
                  activeIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                  height: 80,
                  backgroundColor: TTColors.background_second.withOpacity(0.5),
                  gapLocation: GapLocation.center,
                  notchSmoothness: NotchSmoothness.verySmoothEdge,
                  leftCornerRadius: 24,
                  rightCornerRadius: 24,
                  splashColor: Colors.transparent,
                  splashRadius: 0,
                  elevation: 0,
                  // shadow: BoxShadow(
                  //   color: Colors.white.withOpacity(0.12),
                  //   blurRadius: 32,
                  //   spreadRadius: -4,
                  // ),
                  borderColor: TTColors.input,
                  borderWidth: 1.8,
                  scaleFactor: 0.0,
                  tabBuilder: (index, isActive) => NavCircleButton(
                    iconAsset: _navSvgs[index],
                    isActive: isActive,
                  ),
                ),
              ),
            ),
          );
  }

  Future<void> _loadUser() async {
    final isAdmin = await UserStorage.whereInRole([UserRole.admin]);

    setState(() {
      _isAdmin = isAdmin ?? _isAdmin;
    });
    _fetchScreens();

    setState(() {
      _isLoading = false;
    });
  }

  void _fetchScreens() {
    setState(() {
      _screens = [
        const Home(),
        const Mention(),
        // if (_isAdmin) const Admin(),
        const Calendar(),
        const User(),
      ];

      // ДОБАВИТЬ: список иконок для animated_bottom_navigation_bar
      _navSvgs = [
        'assets/svg/home.svg',
        'assets/svg/car.svg',
        // if (_isAdmin) 'assets/svg/calendar.svg',
        'assets/svg/calendar.svg',
        'assets/svg/user.svg',
      ];
    });
  }
}

//           // Positioned.fill(
//           //   child: ClipRRect(
//           //     borderRadius: BorderRadius.circular(24),
//           //     child: BackdropFilter(
//           //       filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//           //       child: Container(
//           //         decoration: BoxDecoration(
//           //           border: Border.all(
//           //             color: Colors.white.withOpacity(0.1),
//           //             width: 2,
//           //           ),
//           //           gradient: LinearGradient(
//           //             begin: Alignment.topCenter,
//           //             end: Alignment.bottomCenter,
//           //             colors: [
//           //               Colors.white.withOpacity(0.12),
//           //               Colors.transparent,
//           //             ],
//           //           ),
//           //         ),
//           //       ),
//           //     ),
//           //   ),
//           // ),
