import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:tooday/database/database_helper.dart';
import 'package:tooday/main.dart';
import 'package:tooday/models/todo.dart';
import 'package:tooday/screens/about_screen.dart';
import 'package:tooday/screens/todo_list_screen.dart';
import 'package:tooday/utils/app_localization.dart';
import 'package:tooday/utils/connectivity_provider.dart';
import 'package:tooday/utils/google_pay_enable_provider.dart';
import 'package:tooday/utils/language.dart';
import 'package:tooday/utils/filterItemsProvider.dart';
import 'package:tooday/utils/notifications_enable_provider.dart';
import 'package:tooday/utils/shopping_enabled_provider.dart';
import 'package:tooday/utils/stay_on_page_provider.dart';
import 'package:tooday/utils/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:tooday/widgets/google_button.dart';
import '../widgets/custom_page_route.dart';

class SettingsPage extends StatefulWidget {
  final int itemsChecked;
  final List<Todo> listTodos;

  const SettingsPage({
    super.key,
    required this.itemsChecked,
    required this.listTodos,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Language? _selectedLanguage;
  late List<Language> supportedLanguages;

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

  void _onLanguageSelected(Language? language) async {
    if (language == null) return;

    setState(() {
      _selectedLanguage = language;
    });

    TodoApp.setLocale(context, language.locale);
  }

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final stayProvider = Provider.of<StayOnPageProvider>(context);
    final checkedProvider = Provider.of<FilterItemsProvider>(context);
    final shoppingdProvider = Provider.of<ShoppingEnabledProvider>(context);
    final googlePaydProvider = Provider.of<GooglePayEnabledProvider>(context);
    final notificationsdProvider =
        Provider.of<NotificationsEnabledProvider>(context);
    final connectivityProvider = Provider.of<ConnectivityStatus>(context);

    return WillPopScope(
      onWillPop: () {
        if (isForDataManagement || budgetLimitEntered) {
          Navigator.of(context).pushAndRemoveUntil(
            CustomPageRoute(
              child: TodoListScreen(),
              forwardAnimation: false,
              duration: Duration(milliseconds: 500),
            ),
            (route) => false, // Remove all previous routes
          );
        }

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
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.dark_mode,
                          color: themeProvider.isDarkThemeEnabled
                              ? Color.fromARGB(255, 146, 198, 224)
                              : Colors.blueGrey[800],
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context).translate('Dark Theme'),
                          style: TextStyle(
                            fontSize: 16,
                            color: themeProvider.isDarkThemeEnabled
                                ? Color.fromARGB(255, 146, 198, 224)
                                : Colors.blueGrey[800],
                          ),
                        ),
                      ],
                    ),
                    trailing: Switch(
                      value: themeProvider.isDarkThemeEnabled,
                      onChanged: (value) {
                        themeProvider.isDarkThemeEnabled = value;
                      },
                      activeColor: themeProvider.isDarkThemeEnabled
                          ? Color.fromARGB(255, 146, 198, 224)
                          : Colors.blueGrey[800],
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
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.language,
                                size: 32,
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)
                                          .translate('Language Selection'),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: themeProvider.isDarkThemeEnabled
                                            ? Colors.white
                                            : Colors.grey[800],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    DropdownButton<Language>(
                                      value: _selectedLanguage,
                                      onChanged: _onLanguageSelected,
                                      hint: Text(
                                        AppLocalizations.of(context)
                                            .translate('Select'),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              themeProvider.isDarkThemeEnabled
                                                  ? Colors.white
                                                  : Colors.grey[500],
                                        ),
                                      ),
                                      underline: SizedBox(),
                                      items: supportedLanguages.map((language) {
                                        return DropdownMenuItem<Language>(
                                          value: language,
                                          child: Text(
                                            language.name,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: themeProvider
                                                      .isDarkThemeEnabled
                                                  ? Colors.white
                                                  : Colors.grey[800],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
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
                  elevation: 1,
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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: stayProvider.isStayOnPAgeEnabled
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: stayProvider.isStayOnPAgeEnabled
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        : null,
                                  ),
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
                        ),
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color:
                                              checkedProvider.showCheckedItems
                                                  ? Colors.greenAccent
                                                  : Colors.grey,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        color: checkedProvider.showCheckedItems
                                            ? Colors.greenAccent
                                                .withOpacity(0.1)
                                            : null,
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
                                                    : Color.fromARGB(
                                                        255, 207, 207, 207),
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
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: checkedProvider
                                                        .showCheckedItems
                                                    ? themeProvider
                                                            .isDarkThemeEnabled
                                                        ? Colors.white
                                                        : Colors.black
                                                    : Color.fromARGB(
                                                        255, 207, 207, 207),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
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
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      side: BorderSide(color: Colors.red)),
                                  onPressed: () {
                                    setState(() {
                                      isForDataManagement = true;
                                      isDataErased = false;
                                    });
                                    if (shoppingdProvider
                                        .geIsShoppingtEnabled) {
                                      dbHelper.deleteAllShoppingItems();
                                      setState(() {
                                        isDataErased = true;
                                      });
                                    } else {
                                      dbHelper
                                          .deleteAllTodoExceptShoppingItems();
                                      setState(() {
                                        isDataErased = true;
                                      });
                                    }
                                  },
                                  child: Text(
                                    isDataErased
                                        ? AppLocalizations.of(context)
                                            .translate('Data  Cleared')
                                        : AppLocalizations.of(context)
                                            .translate('Clear Data'),
                                    style: TextStyle(
                                        color: themeProvider.isDarkThemeEnabled
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      side: BorderSide(color: Colors.red)),
                                  onPressed: () {
                                    // Handle Clear Selected action

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
                                  child: Text(
                                    isCheckedItemsErased
                                        ? AppLocalizations.of(context)
                                            .translate('Checked Items Cleared')
                                        : AppLocalizations.of(context)
                                                .translate(
                                                    'Clear Checked Items') +
                                            '(${widget.itemsChecked})',
                                    style: TextStyle(
                                        color: themeProvider.isDarkThemeEnabled
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
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
                                    'Enable Shopping List',
                                  ),
                                  maxLines: 3,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
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
                                        color:
                                            shoppingdProvider.isSoppingEnabled
                                                ? Colors.greenAccent
                                                : Colors.blueGrey,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        border: Border.all(
                                          color:
                                              shoppingdProvider.isSoppingEnabled
                                                  ? Colors.greenAccent
                                                  : Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                      child: Text(
                                        shoppingdProvider.isSoppingEnabled
                                            ? AppLocalizations.of(context)
                                                .translate(
                                                    'Shopping is Enabled')
                                            : AppLocalizations.of(context)
                                                .translate(
                                                    'Normal Todo List activated'),
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: shoppingdProvider
                                                  .isSoppingEnabled
                                              ? themeProvider.isDarkThemeEnabled
                                                  ? Colors.white
                                                  : Colors.white
                                              : themeProvider.isDarkThemeEnabled
                                                  ? Colors.white
                                                  : Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Switch(
                              value: shoppingdProvider.geIsShoppingtEnabled,
                              onChanged: (value) async {
                                setState(() {
                                  shoppingdProvider.isSoppingEnabled = value;
                                });
                                _saveShoppingValue(value);

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        AppLocalizations.of(context)
                                            .translate('Restart App'),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      content: Text(
                                        AppLocalizations.of(context).translate(
                                          'You need to restart the app for changes to take effect.',
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            restartApp(context);
                                          },
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .translate('OK'),
                                            style: TextStyle(
                                              color: themeProvider
                                                      .isDarkThemeEnabled
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        shoppingdProvider.geIsShoppingtEnabled
                            ? Padding(
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
                                        color: Colors.black87,
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
                                                .translate(
                                                'Enter your budget limit',
                                              )
                                            : budgetLimit.toStringAsFixed(2),
                                        hintStyle: TextStyle(
                                          color: Colors.black,
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
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.all(16.0),
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
                                      color: themeProvider.isDarkThemeEnabled
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
                                      !googlePaydProvider.isGooglePaytEnabled;
                                });
                                saveGooglePay(
                                    googlePaydProvider.isGooglePaytEnabled);
                              },
                              icon: Icon(
                                Icons.payment_outlined,
                                color: googlePaydProvider.geIsGooglePaytEnabled
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
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text(AppLocalizations.of(context).translate(
                            'Enable Notifications',
                          )),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                notificationsdProvider.isNotificationstEnabled =
                                    !notificationsdProvider
                                        .isNotificationstEnabled;
                              });
                              saveNotificationAlalrm(notificationsdProvider
                                  .isNotificationstEnabled);
                            },
                            icon: Icon(
                              Icons.alarm,
                              color: notificationsdProvider
                                      .geIsNotificationstEnabled
                                  ? Color.fromARGB(255, 16, 186, 192)
                                  : themeProvider.isDarkThemeEnabled
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                connectivityProvider.isConnected
                    ? GoogleSignInButton()
                    : Card(
                        elevation: 4.0,
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
                  elevation: 4.0,
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

  void restartApp(BuildContext ctx) {
    Phoenix.rebirth(ctx);
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
