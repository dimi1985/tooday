// ignore_for_file: must_be_immutable

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:iconly/iconly.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tooday/database/database_helper.dart';
import 'package:tooday/main.dart';
import 'package:tooday/models/todo.dart';
import 'package:tooday/screens/about_screen.dart';
import 'package:tooday/screens/todo_list_screen.dart';
import 'package:tooday/utils/app_localization.dart';
import 'package:tooday/utils/back_service_provider.dart';
import 'package:tooday/utils/connectivity_provider.dart';
import 'package:tooday/utils/google_pay_enable_provider.dart';
import 'package:tooday/utils/language.dart';
import 'package:tooday/utils/filterItemsProvider.dart';
import 'package:tooday/utils/notification_timing_provider.dart';
import 'package:tooday/utils/repeat_notification_provider.dart';
import 'package:tooday/utils/shopping_enabled_provider.dart';
import 'package:tooday/utils/stay_on_page_provider.dart';
import 'package:tooday/utils/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooday/utils/time_periodic_provider.dart';
import 'package:tooday/widgets/google_button.dart';
import '../widgets/custom_page_route.dart';

class SettingsPage extends StatefulWidget {
  final int itemsChecked;
  final List<Todo> listTodos;
  bool isUserSignIn;

  SettingsPage({
    super.key,
    required this.itemsChecked,
    required this.listTodos,
    required this.isUserSignIn,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late List<Language> supportedLanguages;
  int _selectedLanguageIndex = 1; // Default to Greek

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    supportedLanguages = [
      Language(AppLocalizations.of(context).translate('English'),
          const Locale('en', 'US')),
      Language(AppLocalizations.of(context).translate('Greek'),
          const Locale('el', 'GR')),
    ];
  }

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      final languageCode = prefs.getString('languageCode');
      final countryCode = prefs.getString('countryCode');
      if (languageCode != null && countryCode != null) {
        final locale = Locale(languageCode, countryCode);
        final selectedLanguage = supportedLanguages.firstWhere(
          (language) => language.locale == locale,
          orElse: () => supportedLanguages[0],
        );

        setState(() {
          _selectedLanguageIndex = supportedLanguages.indexOf(selectedLanguage);
        });

        TodoApp.setLocale(context, locale);
      }
    });

    _getBudgetValue();
  }

  @override
  void dispose() {
    _budgetLimitController.dispose();
    super.dispose();
  }

  DatabaseHelper dbHelper = DatabaseHelper();
  late bool isForDataManagement = false;
  bool isDataErased = false;
  bool isCheckedItemsErased = false;
  final _budgetLimitController = TextEditingController();
  double budgetLimit = 0.0;
  bool budgetLimitEntered = false;
  String notiService = '';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final stayProvider = Provider.of<StayOnPageProvider>(context);
    final checkedProvider = Provider.of<FilterItemsProvider>(context);
    final shoppingdProvider = Provider.of<ShoppingEnabledProvider>(context);
    final googlePaydProvider = Provider.of<GooglePayEnabledProvider>(context);
    final connectivityProvider = Provider.of<ConnectivityStatus>(context);
    final backgroundServiceProvider =
        Provider.of<BackgroundServiceProvider>(context);
    final repeatNotificationsProvider =
        Provider.of<RepeatNotificationsProvider>(context);
    final periodicTimeIProvider = Provider.of<TimePeriodicProvider>(context);
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushAndRemoveUntil(
          CustomPageRoute(
            child: TodoListScreen(),
            forwardAnimation: false,
            duration: Duration(milliseconds: 500),
          ),
          (route) => false,
        );

        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: themeProvider.isDarkThemeEnabled
            ? Color.fromARGB(255, 37, 37, 37)
            : Theme.of(context).colorScheme.onPrimary,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color:
                themeProvider.isDarkThemeEnabled ? Colors.white : Colors.black,
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkThemeEnabled
                            ? Colors.white
                            : Colors.blueGrey[800],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                2, // Two items for Light Theme and Dark Theme
                            itemBuilder: (BuildContext context, int index) {
                              bool isDarkTheme = index == 1;
                              bool isSelected = isDarkTheme ==
                                  themeProvider.isDarkThemeEnabled;

                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    themeProvider.isDarkThemeEnabled =
                                        isDarkTheme;
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey[200],
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isDarkTheme
                                                ? Icons.dark_mode
                                                : Icons.light_mode,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.blueGrey[800],
                                          ),
                                          SizedBox(width: 10),
                                          SizedBox(
                                            width: 80,
                                            child: Text(
                                              isDarkTheme
                                                  ? AppLocalizations.of(context)
                                                      .translate('Dark Theme')
                                                  : AppLocalizations.of(context)
                                                      .translate('Light Theme'),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey[800],
                                              ),
                                              maxLines: 3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate('Language'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkThemeEnabled
                              ? Colors.white
                              : Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 8),
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: supportedLanguages.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final language = supportedLanguages[index];
                                    final isSelected =
                                        index == _selectedLanguageIndex;

                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedLanguageIndex = index;
                                          });
                                          TodoApp.setLocale(
                                              context, language.locale);
                                        },
                                        child: SizedBox(
                                          width: 110,
                                          height: 110,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 16.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              color: isSelected
                                                  ? Colors.blue
                                                  : Colors.grey[200],
                                            ),
                                            child: Center(
                                              child: Text(
                                                language.name,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey[800],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListTile(
                          title: Text(
                            AppLocalizations.of(context).translate(
                              'Stay on add todo screen when adding ?',
                            ),
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: stayProvider.isStayOnPAgeEnabled
                                      ? Theme.of(context).colorScheme.secondary
                                      : Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: stayProvider.isStayOnPAgeEnabled
                                    ? Theme.of(context).colorScheme.secondary
                                    : null,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    stayProvider.isStayOnEnabled =
                                        !stayProvider.isStayOnEnabled;
                                  });
                                  saveStayValue(stayProvider.isStayOnEnabled);
                                },
                                child: Center(
                                  child: Text(
                                    stayProvider.isStayOnPAgeEnabled
                                        ? AppLocalizations.of(context)
                                            .translate('Enabled')
                                        : AppLocalizations.of(context)
                                            .translate('Disabled'),
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: stayProvider.isStayOnPAgeEnabled
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSecondary
                                          : Color.fromARGB(255, 207, 207, 207),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context).translate('Data Settings'),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    title: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  AppLocalizations.of(context).translate(
                                    'Select to filter between Checked or Unckecked Items',
                                  ),
                                  maxLines: 3,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: themeProvider.isDarkThemeEnabled
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        checkedProvider.showCheckedItems =
                                            !checkedProvider.showCheckedItems;
                                      });
                                      _saveCheckedItems(
                                          checkedProvider.showCheckedItems);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: checkedProvider.showCheckedItems
                                            ? Colors.greenAccent
                                                .withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            checkedProvider.showCheckedItems
                                                ? Icons.check_box_outlined
                                                : Icons.check_box_outline_blank,
                                            color:
                                                checkedProvider.showCheckedItems
                                                    ? Colors.greenAccent
                                                    : Colors.grey,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              checkedProvider.showCheckedItems
                                                  ? AppLocalizations.of(context)
                                                      .translate(
                                                          'Show Checked Items')
                                                  : AppLocalizations.of(context)
                                                      .translate(
                                                          'Show UnChecked Items'),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: themeProvider
                                                        .isDarkThemeEnabled
                                                    ? Colors.white
                                                    : Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 50,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isForDataManagement = true;
                                    isDataErased = false;
                                  });

                                  if (shoppingdProvider.geIsShoppingtEnabled) {
                                    dbHelper.deleteAllShoppingItems();
                                    setState(() {
                                      isDataErased = true;
                                    });
                                  } else {
                                    dbHelper.deleteAllTodoExceptShoppingItems();
                                    setState(() {
                                      isDataErased = true;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: isDataErased
                                        ? Colors.greenAccent.withOpacity(0.1)
                                        : const Color.fromARGB(255, 151, 57, 57)
                                            .withOpacity(0.1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      isDataErased
                                          ? AppLocalizations.of(context)
                                              .translate('Data Cleared')
                                          : AppLocalizations.of(context)
                                              .translate('Clear Data'),
                                      style: TextStyle(
                                          color:
                                              themeProvider.isDarkThemeEnabled
                                                  ? Colors.white
                                                  : Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            SizedBox(
                              height: 50,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isForDataManagement = true;
                                    isCheckedItemsErased = false;
                                  });

                                  widget.listTodos
                                      .removeWhere((todo) => todo.isDone);
                                  dbHelper.deleteDoneTodos();

                                  setState(() {
                                    isCheckedItemsErased = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: isCheckedItemsErased || isDataErased
                                        ? Colors.greenAccent.withOpacity(0.1)
                                        : const Color.fromARGB(255, 151, 57, 57)
                                            .withOpacity(0.1),
                                  ),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Text(
                                          isCheckedItemsErased || isDataErased
                                              ? AppLocalizations.of(context)
                                                  .translate(
                                                      'Checked Items Cleared')
                                              : AppLocalizations.of(context)
                                                  .translate(
                                                      'Clear Checked Items'),
                                          style: TextStyle(
                                              color: themeProvider
                                                      .isDarkThemeEnabled
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                        if (isCheckedItemsErased ||
                                            isDataErased)
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: themeProvider
                                                        .isDarkThemeEnabled
                                                    ? Colors.white
                                                    : Color.fromARGB(
                                                        211, 80, 80, 80),
                                              ),
                                              padding: EdgeInsets.all(
                                                  9.0), // Adjust padding as needed
                                              child: Center(
                                                child: Text(
                                                  '${widget.itemsChecked}',
                                                  style: TextStyle(
                                                    color: themeProvider
                                                            .isDarkThemeEnabled
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context).translate('List Selection'),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 2,
                          itemBuilder: (BuildContext context, int index) {
                            String title = index == 0
                                ? AppLocalizations.of(context)
                                    .translate('Todo List')
                                : AppLocalizations.of(context)
                                    .translate('Shopping List');

                            bool isSelected = index == 0
                                ? !shoppingdProvider.isSoppingEnabled
                                : shoppingdProvider.isSoppingEnabled;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  shoppingdProvider.isSoppingEnabled =
                                      index == 1;
                                });
                                _saveShoppingValue(
                                    shoppingdProvider.isSoppingEnabled);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0, vertical: 4.0),
                                child: Container(
                                  width: 160,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? isSelected
                                            ? Color.fromARGB(255, 19, 82, 107)
                                            : const Color.fromARGB(
                                                255, 131, 131, 131)
                                        : isSelected
                                            ? Color.fromARGB(255, 19, 82, 107)
                                            : const Color.fromARGB(
                                                255, 131, 131, 131),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: isSelected ? 18 : 14,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (shoppingdProvider.geIsShoppingtEnabled)
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('Shopping List Settings'),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (shoppingdProvider.geIsShoppingtEnabled)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).translate(
                                  'Budget Limit',
                                ),
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.isDarkThemeEnabled
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                AppLocalizations.of(context).translate(
                                  'Hint: 0 equals to unlimited',
                                ),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              TextField(
                                style: TextStyle(color: Colors.black),
                                controller: _budgetLimitController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: budgetLimit == 0.0
                                      ? AppLocalizations.of(context)
                                          .translate('Enter your budget limit')
                                      : budgetLimit.toStringAsFixed(2),
                                  hintStyle: TextStyle(
                                    color: themeProvider.isDarkThemeEnabled
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 16.0,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                onChanged: (value) {
                                  double parsedValue =
                                      _budgetLimitController.text.isEmpty
                                          ? 0.0
                                          : double.parse(value);

                                  _saveBudgetValue(parsedValue);
                                  setState(() {
                                    budgetLimitEntered = true;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      if (shoppingdProvider.geIsShoppingtEnabled)
                        ListTile(
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/google_pay.png',
                                        height: 30.0,
                                      ),
                                      SizedBox(width: 16.0),
                                      Text(
                                        AppLocalizations.of(context)
                                            .translate('Enable Google Pay'),
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                themeProvider.isDarkThemeEnabled
                                                    ? Colors.white
                                                    : Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        googlePaydProvider.isGooglePaytEnabled =
                                            !googlePaydProvider
                                                .isGooglePaytEnabled;
                                      });
                                      saveGooglePay(googlePaydProvider
                                          .isGooglePaytEnabled);
                                    },
                                    icon: Icon(
                                      Icons.payment_outlined,
                                      color: googlePaydProvider
                                              .geIsGooglePaytEnabled
                                          ? Color.fromARGB(255, 16, 186, 192)
                                          : themeProvider.isDarkThemeEnabled
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                          color: backgroundServiceProvider.isServiceEnabled
                              ? Color.fromARGB(255, 114, 189, 250)
                              : const Color.fromARGB(255, 2, 67, 121),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('Enable Background Service'),
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Flexible(
                              child: SizedBox(
                                width: 130,
                                child: Switch(
                                  value: backgroundServiceProvider
                                      .isServiceEnabled,
                                  onChanged: (value) async {
                                    final services = FlutterBackgroundService();
                                    bool isRunning = await services.isRunning();
                                    backgroundServiceProvider
                                        .toggleService(value);

                                    await Permission.notification.status
                                        .then((status) {
                                      if (status.isDenied) {
                                        Permission.notification.request();
                                      } else if (status.isGranted) {
                                        // Notification permission has already been granted
                                        // You can proceed with using notifications
                                      }
                                    });

                                    if (!backgroundServiceProvider
                                        .isServiceEnabled) {
                                      if (isRunning) {
                                        services.invoke('stopService');
                                      } else {
                                        services.startService();
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (backgroundServiceProvider.isServiceEnabled)
                        Container(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate('Notification Interval'),
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Consumer<NotificationTimingProvider>(
                                      builder: (context, provider, _) {
                                        return ListTile(
                                            trailing: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border:
                                                Border.all(color: Colors.grey),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<int>(
                                              value:
                                                  provider.notificationInterval,
                                              onChanged: (value) {
                                                provider
                                                    .updateNotificationInterval(
                                                        value!);

                                                if (value == 0) {
                                                  setState(() {
                                                    periodicTimeIProvider
                                                            .isTimePeriodicEnabled =
                                                        false;
                                                  });
                                                  periodicTimeIProvider
                                                      .updateTimePeriodic(
                                                          periodicTimeIProvider
                                                              .isTimePeriodicEnabled);
                                                } else {
                                                  setState(() {
                                                    periodicTimeIProvider
                                                            .isTimePeriodicEnabled =
                                                        true;
                                                  });
                                                  periodicTimeIProvider
                                                      .updateTimePeriodic(
                                                          periodicTimeIProvider
                                                              .isTimePeriodicEnabled);
                                                }
                                              },
                                              items: [
                                                DropdownMenuItem<int>(
                                                  value: 0,
                                                  child: Text(
                                                      '${AppLocalizations.of(context).translate('No')}'),
                                                ),
                                                DropdownMenuItem<int>(
                                                  value: 1,
                                                  child: Text(
                                                      '1 ${AppLocalizations.of(context).translate('minute')}'),
                                                ),
                                                DropdownMenuItem<int>(
                                                  value: 5,
                                                  child: Text(
                                                      '5 ${AppLocalizations.of(context).translate('minutes')}'),
                                                ),
                                                DropdownMenuItem<int>(
                                                  value: 15,
                                                  child: Text(
                                                      '15 ${AppLocalizations.of(context).translate('minutes')}'),
                                                ),
                                                DropdownMenuItem<int>(
                                                  value: 30,
                                                  child: Text(
                                                      '30 ${AppLocalizations.of(context).translate('minutes')}'),
                                                ),
                                                DropdownMenuItem<int>(
                                                  value: 60,
                                                  child: Text(
                                                      '1 ${AppLocalizations.of(context).translate('Hour')}'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ));
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (backgroundServiceProvider.isServiceEnabled)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)
                                    .translate('Repeat Notifications'),
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(width: 20),
                              IconButton(
                                icon: Icon(
                                  repeatNotificationsProvider
                                          .repeatNotifications
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: repeatNotificationsProvider
                                          .repeatNotifications
                                      ? Colors.green
                                      : Colors.red,
                                  size: 30,
                                ),
                                onPressed: () {
                                  setState(() {
                                    repeatNotificationsProvider
                                            .isRepeatNotifications =
                                        !repeatNotificationsProvider
                                            .isRepeatNotifications;
                                  });
                                  repeatNotificationsProvider
                                      .updateRepeatNotifications(
                                          repeatNotificationsProvider
                                              .isRepeatNotifications);
                                },
                              ),
                            ],
                          ),
                        ),
                      if (backgroundServiceProvider.isServiceEnabled)
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(
                                255, 69, 50, 238), // Blue-Grey color
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)
                                    .translate('Background Services Alert'),
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                AppLocalizations.of(context).translate(
                                    'Please ensure that the app is allowed to run in the background without battery optimizations. This will ensure proper functioning of background services and notifications. Go to battery settings to make necessary adjustments.Keep In mind that for now backround services time start as soon as the app is a background state.'),
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              MaterialButton(
                                onPressed: () {
                                  // Open battery optimization settings
                                  AppSettings.openAppSettings();
                                },
                                child: Text(
                                  AppLocalizations.of(context).translate(
                                      'Open Battery Optimization Settings'),
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                connectivityProvider.isConnected
                    ? GoogleSignInButton()
                    : Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.online_prediction,
                            size: 22.0,
                            color: themeProvider.isDarkThemeEnabled
                                ? Color.fromARGB(255, 202, 202, 202)
                                : Colors.grey,
                          ),
                          title: Text(
                            AppLocalizations.of(context).translate(
                                'You need to be Connected to the Internet to use Google Account'),
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkThemeEnabled
                                    ? Color.fromARGB(255, 202, 202, 202)
                                    : Colors.grey),
                          ),
                        ),
                      ), // Add the Google Sign-In button here
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    leading: Icon(
                      IconlyBold.notification,
                      size: 30.0,
                      color: themeProvider.isDarkThemeEnabled
                          ? Colors.white
                          : Colors.black,
                    ),
                    title: Text(
                      AppLocalizations.of(context).translate('About'),
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkThemeEnabled
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutPage()),
                      );
                    },
                  ),
                )
              ],
            ),
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

  void _saveShoppingValue(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSoppingEnabled', value);
  }

  bool returnTrue() {
    return true;
  }

  void _saveBudgetValue(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('budgetValue', value);
  }

  void _getBudgetValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      budgetLimit = prefs.getDouble(
            'budgetValue',
          ) ??
          0;
    });
  }

  void saveNotificationAlalrm(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRunning', value);
  }

  void saveGooglePay(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGooglePayEnabled', value);
  }
}
