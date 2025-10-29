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

  List<String> _navSvgs = [];

  @override
  void initState() {
    super.initState();

    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(body: CenterLoadingModule)
        : Scaffold(
            backgroundColor: TTColors.background,
            extendBody: true,
            // appBar: CustomAppBar(userName),
            appBar: AppBar(
              toolbarHeight: 20,
              backgroundColor: Colors.transparent,
            ),
            body: _screens[_currentIndex],
            // SingleChildScrollView(
            //   physics: const BouncingScrollPhysics(),
            //   child: Padding(
            //     padding: const EdgeInsets.fromLTRB(16, 16, 16, 113),
            //     // 👈 73 (высота бара) + запас
            //     child: _screens[_currentIndex],
            //   ),
            // ),

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
              height: 73,
              backgroundColor: TTColors.background_second,
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
              borderColor: TTColors.card,
              borderWidth: 1.8,
              scaleFactor: 0.0,
              tabBuilder: (index, isActive) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Transform.scale(
                  scale: 0.8,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? TTColors.input_focused
                              .withOpacity(0.28) // активный фон кружка
                          : TTColors.input_focused.withOpacity(0.18), // дефолт
                      border: Border.all(
                        color: isActive
                            ? Colors.white.withOpacity(0.95) // яркое кольцо
                            : Colors.black.withOpacity(0.20), // тонкое кольцо
                        width: isActive ? 1.8 : 1.0,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                // светящееся свечение
                                color: Colors.white.withOpacity(0.15),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ]
                          : [
                              BoxShadow(
                                // лёгкая тень по умолчанию
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        // размер SVG
                        constraints: const BoxConstraints.tightFor(
                            width: 30, height: 30),
                        child: SvgPicture.asset(
                          _navSvgs[index],
                          colorFilter: ColorFilter.mode(
                            isActive
                                ? Colors.white
                                : Colors.white.withOpacity(0.55),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Future<void> _loadUser() async {
    final name = await UserStorage.getUserName();
    final isAdmin = await UserStorage.whereInRole([UserRole.admin]);

    setState(() {
      userName = name ?? userName;
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
        if (_isAdmin) const Admin(),
        const User(),
      ];

      // ДОБАВИТЬ: список иконок для animated_bottom_navigation_bar
      _navSvgs = [
        'assets/svg/home.svg',
        'assets/svg/car.svg',
        if (_isAdmin) 'assets/svg/calendar.svg',
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
