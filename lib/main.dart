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

import 'Services/PushNotificationService.dart';
import 'Storage/Cache/AccentColorCache.dart';
import 'config/HardConfig.dart';
import 'config/LoadingTypeConfig.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Обов'язково ініціалізуємо Firebase у фоновому процесі
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void _handleMessage(RemoteMessage message) {
  // Тут твоя однакова логіка для всіх станів
  print("Обробка повідомлення: ${message.notification?.title}");

  if (message.data['type'] == 'giveaway') {
    // Наприклад, перехід на конкретний екран
    // navKey.currentState?.pushNamed('/nav');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final pushService = PushNotificationService();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await pushService.initialize();

  await AccentColorCache.init();
  await initializeDateFormatting('uk_UA', null);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  const flavorStr = String.fromEnvironment('type', defaultValue: 'standard');
  /** flutter run --dart-define=type=public */
  LoadingTypeConfig.type =
      flavorStr == 'public' ? LoadingType.public : LoadingType.standard;
  try {
    await HardConfig.init();
  } catch (e) {
    print("Failed to initialize version: $e");
  }

  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    // <--- Додай цей рядок
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 30),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      scaffoldBackgroundColor: Colors.white,
      primarySwatch: Colors.amber,
    ),
    initialRoute: '/onboarding',
    routes: {
      '/onboarding': (context) => Onboarding(),
      '/login': (context) => Login(),
      '/nav': (context) => Nav(),
    },
  ));

  //  // Обов'язково додаємо цей рядок для асинхронних операцій у main
  // WidgetsFlutterBinding.ensureInitialized();
  //
  // await AccentColorCache.init();
  // await initializeDateFormatting('uk_UA', null);
  //
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // Ініціалізація Firebase
  //
  // // Запит дозволу на пуші (важливо для iOS та Android 13+)
  // FirebaseMessaging messaging = FirebaseMessaging.instance;
  // NotificationSettings settings = await messaging.requestPermission(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );
  //
  // print('User granted permission: ${settings.authorizationStatus}');
  //
  // // Отримання токена (саме його ти будеш зберігати в БД для відправки пушів)
  // String? token = await messaging.getToken();
  // print("Firebase Token: $token");
  //
  // // Разрешаем только вертикальную ориентацию
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  //
  // try {
  //   await HardConfig.init();
  // } catch (e) {
  //   print("--------------------------");
  //   print("Failed to initialize version: $e");
  //   print("--------------------------");
  // }
  //
  // runApp(MaterialApp(
  //   theme: ThemeData(
  //     appBarTheme: const AppBarTheme(
  //       backgroundColor: Colors.black, // Черная шапка
  //       titleTextStyle: TextStyle(color: Colors.white, fontSize: 30),
  //       iconTheme: IconThemeData(color: Colors.white),
  //     ),
  //     scaffoldBackgroundColor: Colors.white, // Белый фон
  //     primarySwatch: Colors.amber,
  //   ),
  //   initialRoute: '/onboarding',
  //   routes: {
  //     '/onboarding': (context) => Onboarding(),
  //     '/login': (context) => Login(),
  //     '/nav': (context) => Nav(),
  //   },
  // ));
}
