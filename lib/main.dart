import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooday/screens/splash_screen.dart';
import 'package:tooday/utils/app_localization.dart';
import 'package:tooday/widgets/filterItemsProvider.dart';
import 'package:tooday/widgets/stay_on_page_provider.dart';
import 'package:tooday/widgets/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('languageCode');
  String? countryCode = prefs.getString('countryCode');
  Locale initialLocale = Locale(languageCode ?? 'en', countryCode ?? 'US');

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => StayOnPageProvider()),
      ChangeNotifierProvider(create: (_) => FilterItemsProvider()),
    ],
    child: TodoApp(initialLocale: initialLocale),
  ));
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

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {}
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
