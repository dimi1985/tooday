import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooday/database/database_helper.dart';
import 'package:tooday/models/todo.dart';
import 'package:tooday/screens/splash_screen.dart';
import 'package:tooday/utils/app_localization.dart';
import 'package:tooday/utils/connectivity_provider.dart';
import 'package:tooday/utils/filterItemsProvider.dart';
import 'package:tooday/utils/firebase_user_provider.dart';
import 'package:tooday/utils/firestore_items_provider.dart';
import 'package:tooday/utils/google_pay_enable_provider.dart';
import 'package:tooday/utils/local_nofication_service.dart';
import 'package:tooday/utils/notifications_enable_provider.dart';
import 'package:tooday/utils/stay_on_page_provider.dart';
import 'package:tooday/utils/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tooday/utils/user_signin_provider.dart';
import 'utils/shopping_enabled_provider.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('languageCode');
  String? countryCode = prefs.getString('countryCode');
  Locale initialLocale = Locale(languageCode ?? 'el', countryCode ?? 'GR');

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => StayOnPageProvider()),
      ChangeNotifierProvider(create: (_) => FilterItemsProvider()),
      ChangeNotifierProvider(create: (_) => ShoppingEnabledProvider()),
      ChangeNotifierProvider(create: (_) => GooglePayEnabledProvider()),
      ChangeNotifierProvider(create: (_) => NotificationsEnabledProvider()),
      ChangeNotifierProvider(create: (_) => ConnectivityStatus()),
      ChangeNotifierProvider(create: (_) => FirebaseUserProvider()),
      ChangeNotifierProvider(create: (_) => UserSignInProvider()),
      ChangeNotifierProvider(create: (_) => FireStoreItemsProvider()),
    ],
    child: Phoenix(child: TodoApp(initialLocale: initialLocale)),
  ));

  LocalNotificationService.initialize();

  Workmanager workmanager = Workmanager();

  workmanager.initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
}

class TodoApp extends StatefulWidget {
  final Locale initialLocale;

  const TodoApp({Key? key, required this.initialLocale}) : super(key: key);

  @override
  State<TodoApp> createState() => _TodoAppState();

  static void setLocale(BuildContext context, Locale locale) {
    _TodoAppState? state = context.findAncestorStateOfType<_TodoAppState>();
    if (state != null) {
      state.setLocale(locale);
    }
  }
}

class _TodoAppState extends State<TodoApp> with WidgetsBindingObserver {
  late Locale _locale;

  late AppLifecycleState _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        // App resumed from background
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // App is in background or closed

        if (_lastLifecycleState != AppLifecycleState.resumed) {
          Workmanager().registerPeriodicTask(
            'todoNotificationTask',
            'todo_notification_task',
            frequency: Duration(minutes: 15),
          );
        }
        break;
    }
    _lastLifecycleState = state;
  }

  void setLocale(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    await prefs.setString('countryCode', locale.countryCode!);
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Tooday',
            theme: themeProvider.currentTheme,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('el', 'GR'),
            ],
            locale: _locale,
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}

callbackDispatcher() {
  Workmanager workmanager = Workmanager();
  final dbHelper = DatabaseHelper();
  workmanager.executeTask((taskName, inputData) async {
    // Fetch the due to-do items from the database
    List<Todo> dueTodos = await dbHelper.getUncheckTodos();
    log('callbackDispatcher has Started');
    // Send a notification for each due to-do item
    for (Todo todo in dueTodos) {
      LocalNotificationService.displayNotification(
          id: todo.id ?? 0,
          title: 'To-Do Reminder',
          body: 'Don\'t forget to ${todo.title} today!',
          payload: '');
    }

    // Return success status
    return Future.value(true);
  });
}
