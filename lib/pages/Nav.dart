import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';
import 'package:tt_club_ua/components/CustomAppBar.dart';
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
  List<Widget> _screens = const [Home(), Mention(), User()];
  List<BottomNavigationBarItem> _screensItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Головна'),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Пошук авто'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профіль'),
  ];
  List<IconData> _navIcons = const [Icons.home, Icons.search, Icons.person];

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
            extendBody: true,
            appBar: CustomAppBar(userName),
            body: _screens[_currentIndex],

            // ADD: центральная кнопка под вырез
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: SizedBox(
              width: 64, height: 64,
              // child: FloatingActionButton(
              //   elevation: 0,
              //   onPressed: () {}, // TODO
              //   child: const Icon(Icons.add, size: 28),
              // ),
            ),

            bottomNavigationBar: AnimatedBottomNavigationBar(
              icons: _navIcons,
              activeIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              height: 72,
              backgroundColor: TTColors.background_second,//.withOpacity(0.72),
              shadow: const Shadow(
                color: Colors.white10,
                blurRadius: 25,
                offset: Offset(0, 0),
              ),
              borderColor: TTColors.button_background,// яркий контур
              borderWidth: 3,

              gapLocation: GapLocation.center, // ← вырез по центру
              gapWidth: 100,// ширина выреза (под FAB)
              notchMargin: 10, // зазор между вырезом и FAB
              notchSmoothness: NotchSmoothness.verySmoothEdge,// сглажённые края

              leftCornerRadius: 24,
              rightCornerRadius: 24,
              activeColor: Colors.white,
              inactiveColor: Colors.white54,
              elevation: 0,
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
    // сначала сформировать списки
    _fetchScreens();

    // потом показать UI
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

      _screensItems = [
        const BottomNavigationBarItem(icon: Icon(Icons.home)),
        const BottomNavigationBarItem(icon: Icon(Icons.search)),
        if (_isAdmin)
          const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings)),
        const BottomNavigationBarItem(icon: Icon(Icons.person)),
      ];

      // ДОБАВИТЬ: список иконок для animated_bottom_navigation_bar
      _navIcons = [
        Icons.home,
        Icons.search,
        if (_isAdmin) Icons.admin_panel_settings,
        Icons.person,
      ];
    });
  }
}

// import 'package:flutter/material.dart';
// import 'package:tt_club_ua/Storage/UserStorage.dart';
// import 'package:tt_club_ua/components/CustomAppBar.dart';
// import 'package:tt_club_ua/components/generalModule.dart';
// import 'package:tt_club_ua/config/default.dart';
// import 'package:tt_club_ua/pages/Nav/Home.dart';
// import 'package:tt_club_ua/pages/Nav/Admin.dart';
// import 'package:tt_club_ua/pages/Nav/Mention.dart';
// import 'package:tt_club_ua/pages/Nav/User.dart';
//
// class Nav extends StatefulWidget {
//   const Nav({super.key});
//
//   @override
//   State<Nav> createState() => _NavState();
// }
//
// class _NavState extends State<Nav> {
//   String userName = 'unknowns';
//   int _currentIndex = 0;
//   bool _isAdmin = false; // Значение по умолчанию
//   bool _isLoading = true; // Loading state
//   List<Widget> _screens = [];
//   List<BottomNavigationBarItem> _screensItems = [];
//
//   @override
//   void initState() {
//     super.initState();
//
//     _loadUser();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _isLoading
//         ? Scaffold(body: CenterLoadingModule)
//         : Scaffold(
//       appBar: CustomAppBar(userName),
//       body: _screens[_currentIndex],
//       // REPLACE: стандартный BottomNavigationBar на кастомную волну как на скрине
//       bottomNavigationBar: SizedBox(
//         height: 96,
//         child: Stack(
//           children: [
//             // фон панели с центральной «впадиной»
//             Positioned.fill(
//               child: CustomPaint(
//                 painter: _BottomBarPainter(
//                   color: TTColors.background_second.withOpacity(1),
//                   // основной цвет бара
//                   edge: Colors.red, // лёгкая окантовка
//                   // edge: const Color(0xFF2A2A2A),    // лёгкая окантовка
//                 ),
//               ),
//             ),
//
//             // иконки
//             Align(
//               alignment: Alignment.center,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 18),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: List.generate(_screensItems.length, (i) {
//                     final isActive = i == _currentIndex;
//                     final iconWidget = _screensItems[i].icon!;
//                     return GestureDetector(
//                       onTap: () => setState(() => _currentIndex = i),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 180),
//                         width: 48,
//                         height: 48,
//                         decoration: BoxDecoration(
//                           color: TTColors.background,
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.6),
//                               blurRadius: 10,
//                               offset: const Offset(0, 4),
//                             ),
//                             if (isActive)
//                               BoxShadow(
//                                 color: Colors.white.withOpacity(0.16),
//                                 blurRadius: 10,
//                                 spreadRadius: 1,
//                               ),
//                           ],
//                         ),
//                         child: IconTheme(
//                           data: IconThemeData(
//                             color: isActive
//                                 ? Colors.white
//                                 : Colors.white.withOpacity(0.6),
//                             size: 22,
//                           ),
//                           child: iconWidget,
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//
//       // bottomNavigationBar: BottomNavigationBar(
//       //   selectedItemColor: Colors.black,
//       //   unselectedItemColor: Colors.grey,
//       //   backgroundColor: Colors.white,
//       //   currentIndex: _currentIndex,
//       //   // Текущий выбранный индекс
//       //   onTap: (index) {
//       //     setState(() {
//       //       _currentIndex = index; // Обновляем индекс при нажатии
//       //     });
//       //   },
//       //   items: _screensItems,
//       // ),
//     );
//   }
//
//   Future<void> _loadUser() async {
//     final name = await UserStorage.getUserName();
//     final isAdmin = await UserStorage.whereInRole([UserRole.admin]);
//
//     setState(() {
//       userName = name ?? userName;
//       _isAdmin = isAdmin ?? _isAdmin;
//       _isLoading = false;
//     });
//
//     _fetchScreens();
//   }
//
//   void _fetchScreens() {
//     setState(() {
//       _screens = [
//         const Home(),
//         const Mention(),
//         if (_isAdmin) const Admin(),
//         const User(),
//       ];
//
//       _screensItems = [
//         const BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: 'Головна',
//         ),
//         const BottomNavigationBarItem(
//           icon: Icon(Icons.search),
//           label: 'Пошук авто',
//         ),
//         if (_isAdmin)
//           const BottomNavigationBarItem(
//             icon: Icon(
//               Icons.admin_panel_settings,
//               // color: Colors.lightBlueAccent,
//             ),
//             label: 'Адмін',
//           ),
//         const BottomNavigationBarItem(
//           icon: Icon(Icons.person),
//           label: 'Профіль',
//         ),
//       ];
//     });
//   }
// }
//
// // ADD: ниже класса _NavState — отрисовка волнистого бара (без blur-эффектов)
// class _BottomBarPainter extends CustomPainter {
//   final Color color;
//   final Color edge;
//
//   _BottomBarPainter({required this.color, required this.edge});
//
// // REPLACE: метод paint() в _BottomBarPainter — инвертируем кривую (впадина ВНИЗ, как на скрине)
//   @override
//   void paint(Canvas canvas, Size size) {
//     final w = size.width;
//     final h = size.height;
//
// // настраиваемые уровни (подгони под макет)
//     final double topY = 18; // высота у краёв
//     final double shoulder = 30; // высота «плеч» слева/справа
//     final double valley = 54; // глубина центральной впадины
//
//     final path = Path()
//       ..moveTo(0, topY)
//       ..quadraticBezierTo(0, 0.5, w * 0.1, 0)
//       ..lineTo(w * 0.4, 0)
//       ..quadraticBezierTo(w*0.5, h/1.7, w * 0.6, 0)
//       ..lineTo(w * 0.9, 0)
//       ..relativeQuadraticBezierTo(w*0.8, 5, w, topY)
//     // ..cubicTo(w * 0.35, 30, w * 0.20, topY, w * 0.16, topY)
//     // ..lineTo(w * 0.35, shoulder)
//     // ..cubicTo(w * 0.62, valley, w * 0.72, shoulder, w * 0.84, shoulder)
//     // ..lineTo(w, h)
//     // ..cubicTo(w * 0.90, topY + 4, w * 0.94, topY, w, topY)
//       ..lineTo(w, h)
//       ..lineTo(0, h)
//       ..close();
//
// // фон
//     final paint = Paint()..color = color;
//     canvas.drawPath(path, paint);
//
// // окантовка
//     final edgePaint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1
//       ..color = edge;
//     canvas.drawPath(path, edgePaint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
