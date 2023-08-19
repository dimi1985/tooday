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
  late Timer? periodicTimer = null;
  late bool isServiceEnabled;
  late int notificationInterval;
  late bool repeatNotifications;
  late bool isHourSelected;
  late bool isTimePeriodicEnabled;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  isServiceEnabled = prefs.getBool('isServiceEnabled') ?? false;
  notificationInterval = prefs.getInt('notificationInterval') ?? 15;
  repeatNotifications = prefs.getBool('repeatNotifications') ?? false;
  isHourSelected = prefs.getBool('isHourSelected') ?? false;
  int selectedHourHour = prefs.getInt('selectedHourHour') ?? 0;
  int selectedHourMinute = prefs.getInt('selectedHourMinute') ?? 0;
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

  if (!isHourSelected && isTimePeriodicEnabled) {
    print('isHourSelected: $isHourSelected');
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
  } else if (isHourSelected && isTimePeriodicEnabled) {
    print(
        'isHourSelected && isTimePeriodicEnabled: $isHourSelected , $isTimePeriodicEnabled');
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

    // Use other scheduling mechanism based on dueDate and selected hour
    final dbHelper = DatabaseHelper();
    List<Todo> todos = await dbHelper.getIsHourSelectedItems();

    for (var todo in todos) {
      DateTime dueDate =
          DateTime.parse(todo.dueDate); // Parse the dueDate string to DateTime
      TimeOfDay selectedHour =
          TimeOfDay(hour: selectedHourHour, minute: selectedHourMinute);
      print('dueDate: $dueDate');
      print('selectedHour: ${todo.isHourSelected}');
      // Calculate the time difference between dueDate and selected hour
      // Calculate the time difference between dueDate and selected hour
      DateTime scheduledTime = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        selectedHour.hour,
        selectedHour.minute,
      );

      print('scheduledTime: $scheduledTime');

      // Calculate the time difference between now and scheduledTime
      Duration timeDifference = scheduledTime.difference(DateTime.now());

      // Schedule the date-based notification using a timer
      Timer(timeDifference, () async {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: generateUniqueId(),
            wakeUpScreen: true,
            displayOnBackground: true,
            channelKey: 'basic_channel',
            title: 'Reminder',
            body: 'You have a task to do: ${todo.title}',
          ),
        );
      });
    }
  } else if (isHourSelected && !isTimePeriodicEnabled) {
    print('isHourSelected: $isHourSelected');
    // Use other scheduling mechanism based on dueDate and selected hour
    final dbHelper = DatabaseHelper();
    List<Todo> todos = await dbHelper.getIsHourSelectedItems();

    for (var todo in todos) {
      if (!isTimePeriodicEnabled) {
        if (periodicTimer != null && periodicTimer.isActive) {
          print('Cancelling periodicTimer');
          periodicTimer.cancel();
          print('periodicTimer is active: ${periodicTimer.isActive}');
        }
      } else {
        return;
      }
      DateTime dueDate =
          DateTime.parse(todo.dueDate); // Parse the dueDate string to DateTime
      TimeOfDay selectedHour =
          TimeOfDay(hour: selectedHourHour, minute: selectedHourMinute);
      print('dueDate: $dueDate');
      print('selectedHour: ${todo.isHourSelected}');
      // Calculate the time difference between dueDate and selected hour
      // Calculate the time difference between dueDate and selected hour
      DateTime scheduledTime = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        selectedHour.hour,
        selectedHour.minute,
      );

      print('scheduledTime: $scheduledTime');

      // Calculate the time difference between now and scheduledTime
      Duration timeDifference = scheduledTime.difference(DateTime.now());

      // Schedule the date-based notification using a timer
      Timer(timeDifference, () async {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: generateUniqueId(),
            wakeUpScreen: true,
            displayOnBackground: true,
            channelKey: 'basic_channel',
            title: 'Reminder',
            body: 'You have a task to do: ${todo.title}',
          ),
        );
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
