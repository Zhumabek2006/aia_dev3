import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'app.dart';

// Функция для обработки фоновых уведомлений
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Инициализация Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Запрашиваем разрешение на уведомления (для iOS это обязательно, для Android опционально)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // Настройка обработки фоновых уведомлений
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Получаем токен устройства для отправки уведомлений
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  runApp(App());
}