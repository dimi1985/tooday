@pragma('vm:entry-point')
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
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
  late int notificationInterval;
  late bool repeatNotifications;
  late bool isTimePeriodicEnabled;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  notificationInterval = prefs.getInt('notificationInterval') ?? 15;
  repeatNotifications = prefs.getBool('repeatNotifications') ?? false;
  isTimePeriodicEnabled = prefs.getBool('isTimePeriodicEnabled') ?? false;

  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  final dbHelper = DatabaseHelper();
  List<Todo> todos = await dbHelper.getAllUncheckTodos();
  final locale = Locale('el');
  AppLocalizations appLocalizations =
      await AppLocalizations.delegate.load(locale);

  for (var todo in todos) {
    if (isTimePeriodicEnabled) {
      periodicTimer = Timer.periodic(Duration(minutes: notificationInterval),
          (timer) async {
        final locale = Locale('el');
        AppLocalizations appLocalizations =
            await AppLocalizations.delegate.load(locale);
        final dbHelper = DatabaseHelper();

        // Separate notifications for unfinished tasks
        List<Todo> unfinishedTasks = await dbHelper.getUncheckTodos();
        if (unfinishedTasks.isNotEmpty) {
          print('unfinishedTasks : ${unfinishedTasks.length.toString()}');
          for (var task in unfinishedTasks) {
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: generateUniqueId(),
                wakeUpScreen: true,
                displayOnBackground: true,
                channelKey: 'basic_channel',
                title: appLocalizations.translate('Unfinished Task'),
                body:
                    appLocalizations.translate('You have an unfinished task:') +
                        ' ' +
                        task.title,
              ),
            );
          }
        }

        // Separate notifications for unfinished bought items
        List<Todo> unfinishedBoughtItems =
            await dbHelper.getUnBoughtShoppingItems();
        if (unfinishedBoughtItems.isNotEmpty) {
          print(
              'unfinishedBoughtItems : ${unfinishedBoughtItems.length.toString()}');
          for (var item in unfinishedBoughtItems) {
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: generateUniqueId(),
                wakeUpScreen: true,
                displayOnBackground: true,
                channelKey: 'basic_channel',
                title: appLocalizations.translate('UnBought Items'),
                body: appLocalizations.translate('You forgot to buy:') +
                    ' ' +
                    item.title,
              ),
            );
          }
        }

        if (!repeatNotifications) {
          if (periodicTimer != null && periodicTimer.isActive) {
            periodicTimer.cancel();
          }

          service.invoke('stopService');
        }
      });
    }
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
