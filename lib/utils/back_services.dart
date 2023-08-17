@pragma('vm:entry-point')
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooday/models/todo.dart';
import 'package:tooday/utils/app_localization.dart';
import '../database/database_helper.dart';

@pragma('vm:entry-point')
void initBackgroundTask(ServiceInstance service) async {
  late Timer? periodicTimer;
  late bool isServiceEnabled;
  late int notificationInterval;
  late bool repeatNotifications;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  isServiceEnabled = prefs.getBool('isServiceEnabled') ?? false;
  notificationInterval = prefs.getInt('notificationInterval') ?? 15;
  repeatNotifications = prefs.getBool('repeatNotifications') ?? false;

  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Create the second timer for periodic notifications
  if (isServiceEnabled) {
    print('repeatNotifications: $repeatNotifications');
    periodicTimer =
        Timer.periodic(Duration(minutes: notificationInterval), (timer) async {
      final locale = Locale('el');
      AppLocalizations appLocalizations =
          await AppLocalizations.delegate.load(locale);
      final dbHelper = DatabaseHelper();
      List<Todo> unfinishedTasks = await dbHelper.getUncheckTodos();
      List<Todo> unfinishedBoughtItems =
          await dbHelper.getUnBoughtShoppingItems();

      if (unfinishedTasks.isNotEmpty) {
        for (var task in unfinishedTasks) {
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: generateUniqueId(),
              wakeUpScreen: true,
              displayOnBackground: true,
              channelKey: 'basic_channel',
              title: appLocalizations.translate('UnBought Items'),
              body: appLocalizations.translate('You forgot to buy:') +
                  ' ' +
                  task.title,
            ),
          );
        }
      }

      if (unfinishedBoughtItems.isNotEmpty) {
        for (var item in unfinishedBoughtItems) {
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: generateUniqueId(),
              wakeUpScreen: true,
              displayOnBackground: true,
              channelKey: 'basic_channel',
              title: appLocalizations.translate('Unfinished Task'),
              body: appLocalizations.translate('You have an unfinished task:') +
                  ' ' +
                  item.title,
            ),
          );
        }
      }

      if (!repeatNotifications) {
        if (periodicTimer != null && periodicTimer.isActive) {
          print('Cancelling periodicTimer');
          periodicTimer.cancel();
          print('periodicTimer is active: ${periodicTimer.isActive}');
        }

        print('Stopping background service');
        service.invoke('stopService');
      }
    });
  }
}

int generateUniqueId() {
  final random = Random();
  return random.nextInt(2147483647);
}

initializeAndStartBackgroundTask() async {
  final services = FlutterBackgroundService();
  await services.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: initBackgroundTask,
      isForegroundMode: false,
      autoStart: false,
    ),
  );

  services.startService();
}
