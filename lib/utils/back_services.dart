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

  for (var todo in todos) {
    if (!todo.isHourSelected && isTimePeriodicEnabled) {
      periodicTimer = Timer.periodic(Duration(minutes: notificationInterval),
          (timer) async {
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
                body:
                    appLocalizations.translate('You have an unfinished task:') +
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
    } else if (todo.isHourSelected && isTimePeriodicEnabled) {
      periodicTimer = Timer.periodic(Duration(minutes: notificationInterval),
          (timer) async {
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
                body:
                    appLocalizations.translate('You have an unfinished task:') +
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

      // Use other scheduling mechanism based on dueDate and selected hour
      final dbHelper = DatabaseHelper();
      List<Todo> todos = await dbHelper.getIsHourSelectedItems();

      for (var todo in todos) {
        DateTime dueDate = DateTime.parse(
            todo.dueDate); // Parse the dueDate string to DateTime
        TimeOfDay selectedHour = TimeOfDay(
            hour: todo.selectedTimeHour, minute: todo.selectedTimeMinute);

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
    } else if (todo.isHourSelected && !isTimePeriodicEnabled) {
      // Use other scheduling mechanism based on dueDate and selected hour
      final dbHelper = DatabaseHelper();
      List<Todo> todos = await dbHelper.getIsHourSelectedItems();

      for (var todo in todos) {
        DateTime dueDate = DateTime.parse(
            todo.dueDate); // Parse the dueDate string to DateTime
        TimeOfDay selectedHour = TimeOfDay(
            hour: todo.selectedTimeHour, minute: todo.selectedTimeMinute);

        // Calculate the time difference between dueDate and selected hour
        // Calculate the time difference between dueDate and selected hour
        DateTime scheduledTime = DateTime(
          dueDate.year,
          dueDate.month,
          dueDate.day,
          selectedHour.hour,
          selectedHour.minute,
        );

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
