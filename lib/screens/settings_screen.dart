import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:tooday/main.dart';
import 'package:tooday/screens/about_screen.dart';
import 'package:tooday/utils/app_localization.dart';
import 'package:tooday/utils/language.dart';
import 'package:tooday/widgets/filterItemsProvider.dart';
import 'package:tooday/widgets/stay_on_page_provider.dart';
import 'package:tooday/widgets/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Language? _selectedLanguage;

  final List<Language> supportedLanguages = [
    Language('English', const Locale('en', 'US')),
    Language('Greek', const Locale('el', 'GR')),
  ];

  void _onLanguageSelected(Language? language) async {
    if (language == null) return;

    setState(() {
      _selectedLanguage = language;
    });

    TodoApp.setLocale(context, language.locale);
  }

  bool stayOnAddTodoScreen = false;
  bool showCheckedItems = true;
  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      final languageCode = prefs.getString('languageCode');
      final countryCode = prefs.getString('countryCode');
      if (languageCode != null && countryCode != null) {
        final locale = Locale(languageCode, countryCode);
        setState(() {
          _selectedLanguage = supportedLanguages.firstWhere(
            (language) => language.locale == locale,
            orElse: () => supportedLanguages[0],
          );
        });

        TodoApp.setLocale(context, locale);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final stayProvider = Provider.of<StayOnPageProvider>(context);
    final checkedProvider = Provider.of<FilterItemsProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkThemeEnabled
          ? Color.fromARGB(255, 37, 37, 37)
          : Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: themeProvider.isDarkThemeEnabled ? Colors.white : Colors.black,
        ),
        elevation: 0,
        backgroundColor: themeProvider.isDarkThemeEnabled
            ? const Color.fromARGB(255, 37, 37, 37)
            : Colors.white, // Change app bar color here

        title: Text(
          AppLocalizations.of(context).translate('Settings'),
          style: TextStyle(
              color: themeProvider.isDarkThemeEnabled
                  ? Colors.white
                  : Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    AppLocalizations.of(context).translate('Theme'),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: Row(children: [
                    const Icon(Icons.dark_mode),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(AppLocalizations.of(context).translate('Dark Theme'))
                  ]),
                  trailing: Switch(
                    value: themeProvider.isDarkThemeEnabled,
                    onChanged: (value) {
                      themeProvider.isDarkThemeEnabled = value;
                    },
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    AppLocalizations.of(context).translate('Language'),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: Row(children: [
                    const Icon(IconlyBold.discovery),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      AppLocalizations.of(context)
                          .translate('Language Selection'),
                    ),
                    const Spacer(),
                    DropdownButton<Language>(
                      value: _selectedLanguage,
                      onChanged: _onLanguageSelected,
                      hint: Text(
                          AppLocalizations.of(context).translate('Select')),
                      items: supportedLanguages.map((language) {
                        return DropdownMenuItem<Language>(
                          value: language,
                          child: Text(language.name),
                        );
                      }).toList(),
                    ),
                  ]),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    AppLocalizations.of(context).translate('General'),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(
                            AppLocalizations.of(context).translate(
                              'Stay on add todo screen when adding ?',
                            ),
                            maxLines: 3,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: stayProvider.isStayOnPAgeEnabled
                                          ? Colors.blueAccent
                                          : Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Text(
                                  stayProvider.isStayOnPAgeEnabled
                                      ? AppLocalizations.of(context).translate(
                                          'Enabled',
                                        )
                                      : AppLocalizations.of(context).translate(
                                          'Disabled',
                                        ),
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: stayProvider.isStayOnPAgeEnabled
                                        ? themeProvider.isDarkThemeEnabled
                                            ? Colors.white
                                            : Colors.black
                                        : Color.fromARGB(255, 207, 207, 207),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Switch(
                        value: stayProvider.isStayOnPAgeEnabled,
                        onChanged: (value) {
                          setState(() {
                            stayProvider.isStayOnEnabled = value;
                            saveStayValue(value);
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(
                            AppLocalizations.of(context).translate(
                              'Select to filter between Checked or Unckecked Items',
                            ),
                            maxLines: 3,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: checkedProvider.showCheckedItems
                                          ? Colors.greenAccent
                                          : Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Text(
                                  checkedProvider.showCheckedItems
                                      ? AppLocalizations.of(context).translate(
                                          'Show Checked Items',
                                        )
                                      : AppLocalizations.of(context).translate(
                                          'Show UnChecked Items',
                                        ),
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: checkedProvider.showCheckedItems
                                        ? themeProvider.isDarkThemeEnabled
                                            ? Colors.white
                                            : Colors.black
                                        : Color.fromARGB(255, 207, 207, 207),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Switch(
                        value: checkedProvider.isShowGetCheckedItems,
                        onChanged: (value) {
                          setState(() {
                            checkedProvider.showCheckedItems = value;
                          });
                          _saveCheckedItems(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: Row(
                    children: [
                      const Icon(IconlyBold.notification),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        AppLocalizations.of(context).translate('About'),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveStayValue(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stayOnAddTodoScreen', value);
  }

  void _saveCheckedItems(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showCheckedItems', value);
  }
}
