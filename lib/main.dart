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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ініціалізація Firebase
  // Запит дозволу на пуші (важливо для iOS та Android 13+)
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // Отримання токена (саме його ти будеш зберігати в БД для відправки пушів)
  String? token = await messaging.getToken();
  print("Firebase Token: $token");
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
