// import 'package:flutter/material.dart';
// import 'package:tt_club_ua/pages/Login.dart';
// import 'package:tt_club_ua/pages/Nav.dart';
// import 'package:tt_club_ua/pages/Nav/Admin/User/UpdateCarScreen.dart';
//
// void main() => runApp(MaterialApp(
//       theme: ThemeData(
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.black, // Черная шапка
//           titleTextStyle: TextStyle(color: Colors.white, fontSize: 30),
//           iconTheme: IconThemeData(color: Colors.white),
//         ),
//         scaffoldBackgroundColor: Colors.white, // Белый фон
//         primarySwatch: Colors.amber,
//       ),
//       initialRoute: '/login',
//       routes: {
//         '/login': (context) => Login(),
//         '/nav': (context) => Nav(),
//       },
//     ));

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tt_club_ua/pages/Login.dart';
import 'package:tt_club_ua/pages/Nav.dart';
import 'package:tt_club_ua/pages/Nav/Admin/User/UpdateCarScreen.dart';
import 'package:tt_club_ua/pages/Onboarding.dart';

import 'Storage/Cache/AccentColorCache.dart';
import 'config/HardConfig.dart';

Future<void> main() async {
  //  Обов'язково додаємо цей рядок для асинхронних операцій у main
  WidgetsFlutterBinding.ensureInitialized();

  await AccentColorCache.init();
  await initializeDateFormatting('uk_UA', null);
  // try {
  //   await dotenv.load(fileName: ".env");
  // } catch (e) {
  //   debugPrint("Не удалось загрузить .env: $e");
  // }
  // Разрешаем только вертикальную ориентацию
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await HardConfig.init();
  } catch (e) {
    print("--------------------------");
    print("Failed to initialize version: $e");
    print("--------------------------");
  }

  runApp(MaterialApp(
    theme: ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black, // Черная шапка
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 30),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      scaffoldBackgroundColor: Colors.white, // Белый фон
      primarySwatch: Colors.amber,
    ),
    initialRoute: '/onboarding',
    routes: {
      '/onboarding': (context) => Onboarding(),
      '/login': (context) => Login(),
      '/nav': (context) => Nav(),
    },
  ));
}
