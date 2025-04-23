import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'firebase_options.dart';

// Функция для обработки фоновых уведомлений
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Main: Handling a background message: ${message.messageId}");
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Main: Firebase initialized in background handler");
  } catch (e) {
    print("Main: Error initializing Firebase in background handler: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("Main: Starting app initialization");

  try {
    print("Main: Initializing Firebase");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Main: Firebase initialized successfully");
  } catch (e) {
    print("Main: Error initializing Firebase: $e");
    // Можно добавить fallback-логику, если Firebase не инициализируется
    return;
  }

  // Инициализация Firebase Messaging
  print("Main: Initializing Firebase Messaging");
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  try {
    // Запрашиваем разрешение на уведомления
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('Main: User granted permission: ${settings.authorizationStatus}');
  } catch (e) {
    print("Main: Error requesting notification permission: $e");
  }

  // Настройка обработки фоновых уведомлений
  print("Main: Setting up background message handler");
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  try {
    // Получаем токен устройства для отправки уведомлений
    String? token = await messaging.getToken();
    print("Main: FCM Token: $token");
  } catch (e) {
    print("Main: Error getting FCM token: $e");
  }

  print("Main: Running app");
  runApp(App()); // Убрали const, так как конструктор App не const
}