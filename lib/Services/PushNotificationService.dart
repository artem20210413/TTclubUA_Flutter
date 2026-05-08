import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../Storage/UserStorage.dart';
import '../api/routs/fcm.dart';
// import '../api/routs/user.dart'; // Твій метод для API

class PushNotificationService {
  // Singleton патерн, щоб navigatorKey був доступний всюди
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initialize() async {

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (NotificationResponse details) {
      // Тут обробляємо клік по локальному сповіщенню
      print("Клік по локальному пушу: ${details.payload}");
    },);
    // 1. Твій запит дозволів
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) print('Користувач дозволив сповіщення');

      // 2. Слухачі повідомлень (те, що ми винесли з main)

      // Terminated state
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) _handleMessage(initialMessage);

      // Foreground state
      // FirebaseMessaging.onMessage.listen(_handleMessage);
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final notification = message.notification;
        final data = message.data; // Дані, які прийшли без тексту (payload)

        if (notification != null) {
          await flutterLocalNotificationsPlugin.show(
            // Генеруємо унікальний ID, щоб повідомлення не перетирали одне одного
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel', // ID каналу (має збігатися з налаштуваннями в Manifest)
                'Клубні сповіщення',        // Назва каналу в налаштуваннях телефону
                channelDescription: 'Сповіщення про розіграші та новини TT Club UA',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher', // Переконайся, що іконка вірна
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            // Передаємо дані з пуша в локальне сповіщення, щоб обробити клік по ньому
            payload: message.data['type'],
          );

          // Твоя логіка оновлення UI (наприклад, лічильник замовлень або розіграшів)

        }
      });

      // Background state (клік по пушу)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      // 3. Твоя логіка оновлення токена
      _fcm.onTokenRefresh.listen((newToken) async {
        await _sendTokenToBackend(newToken);
      });
    }
  }

  // Обробка кліку/отримання повідомлення
  void _handleMessage(RemoteMessage message) {
    if (kDebugMode) print("🔔 Обробка повідомлення: ${message.notification?.title}");

    // Твоя логіка навігації
    if (message.data['type'] == 'giveaway') {
      navigatorKey.currentState?.pushNamed('/nav');
    }
    // Додай сюди інші роути (Базар, Відрахування тощо)
  }

  // Твій метод отримання токена (викликаємо в main або після логіну)
  Future<void> syncToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      if (kDebugMode) print('Помилка отримання FCM токена: $e');
    }
  }

  // Твій метод відправки на сервер
  Future<void> _sendTokenToBackend(String fcmToken) async {
    final authToken = await UserStorage.getToken();
    if (authToken == null) {
      if (kDebugMode) print('⚠️ Юзер не авторизований, токен не відправлено');
      return;
    }

    if (kDebugMode) print('🚀 Відправка FCM токена на сервер: $fcmToken');

    try {
      API_FCM_TOKEN_SEND(authToken, fcmToken);
      // Тут твій виклик API:
      // await UPDATE_FCM_TOKEN(authToken, token);
    } catch (e) {
      if (kDebugMode) print('❌ Не вдалося оновити токен на бекенді: $e');
    }
  }
}