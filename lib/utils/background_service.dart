import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooday/database/database_helper.dart';

class BackgroundService {
  static const String TAG = "BackgroundService";
  static const String CHANNEL_ID = "BackgroundServiceChannel";
  static const String CHANNEL_NAME = "Background Service Channel";
  static const int NOTIFICATION_ID = 0;

  static const MethodChannel _backgroundChannel =
      MethodChannel('com.example.background_service');

  static SendPort? uiSendPort;
  static bool isRunning = false;

  static Future<void> start() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isRunning = prefs.getBool('isRunning') ?? false;
    if (isRunning) return;
    isRunning = true;

    uiSendPort ??= IsolateNameServer.lookupPortByName('isolate');

    _backgroundChannel.setMethodCallHandler(_handleMethod);

    final androidInitializationSettings =
        AndroidInitializationSettings('app_icon');

    final initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await FlutterLocalNotificationsPlugin().initialize(initializationSettings);

    // await _showNotification();

    while (isRunning) {
      await Future.delayed(Duration(minutes: 1));
      await _checkTodoList();
    }
  }

  static Future<dynamic> _handleMethod(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'startService':
        await _showNotification();
        return 1;
      case 'stopService':
        await _cancelNotification();
        isRunning = false;
        return 1;
      default:
        return null;
    }
  }

  static Future<void> _showNotification() async {
    final androidDetails = AndroidNotificationDetails(CHANNEL_ID, CHANNEL_NAME,
        importance: Importance.max,
        priority: Priority.low,
        playSound: true,
        sound: const UriAndroidNotificationSound('assets/sounds/noti.wav'),
        enableVibration: true);

    final platformDetails = NotificationDetails(android: androidDetails);

    await FlutterLocalNotificationsPlugin().show(NOTIFICATION_ID,
        'Background Service', 'Service is running', platformDetails);
  }

  static Future<void> _cancelNotification() async {
    await FlutterLocalNotificationsPlugin().cancel(NOTIFICATION_ID);

    final androidDetails = AndroidNotificationDetails(CHANNEL_ID, CHANNEL_NAME,
        importance: Importance.max,
        priority: Priority.low,
        playSound: true,
        sound: const UriAndroidNotificationSound('assets/sounds/noti.wav'),
        enableVibration: true);

    final platformDetails = NotificationDetails(android: androidDetails);

    await FlutterLocalNotificationsPlugin().show(NOTIFICATION_ID,
        'Background Service', 'Service has stopped', platformDetails);
  }

  static stop() {
    isRunning = false;
    _cancelNotification();
  }

  static Future<void> _checkTodoList() async {
    final dbHelper = DatabaseHelper();
    final todos = await dbHelper.getAllTodos();
    final todosNotDone = todos.where((element) => !element.isDone);
    if (todosNotDone.isNotEmpty) {
      final androidDetails = AndroidNotificationDetails(
          CHANNEL_ID, CHANNEL_NAME,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: const UriAndroidNotificationSound('assets/sounds/noti.wav'),
          enableVibration: true);

      final platformDetails = NotificationDetails(android: androidDetails);

      await FlutterLocalNotificationsPlugin().show(
          NOTIFICATION_ID,
          'Todo Reminder',
          'You have ${todosNotDone.length} unfinished tasks',
          platformDetails);
    }
  }
}
