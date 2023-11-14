// ignore_for_file: library_private_types_in_public_api
import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooday/models/todo.dart';
import 'package:tooday/screens/add_edit_todo_screen.dart';
import 'package:tooday/screens/checkout_page.dart';
import 'package:tooday/screens/settings_screen.dart';
import 'package:tooday/utils/app_localization.dart';
import 'package:tooday/utils/bags_provider.dart';
import 'package:tooday/utils/connectivity_provider.dart';
import 'package:tooday/utils/google_pay_enable_provider.dart';
import 'package:tooday/utils/shopping_enabled_provider.dart';
import 'package:tooday/utils/user_signin_provider.dart';
import 'package:tooday/widgets/custom_check_box.dart';
import 'package:tooday/widgets/custom_page_route.dart';
import 'package:tooday/utils/filterItemsProvider.dart';
import 'package:tooday/utils/theme_provider.dart';
import '../database/database_helper.dart';
import 'package:iconly/iconly.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late List<Todo> _todos = [];

  int checkedTodosCounT = 0;
  DatabaseHelper dbHelper = DatabaseHelper();
  bool isLoading = true;
  bool _isSearching = false;
  bool isListviewFiltered = false;
  TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = "";
  String titleText = "";
  List<Todo> _filteredTodos = [];
  double totalPrice = 0.0;
  bool isForEdit = false;
  String textError = '';
  double budgetLimit = 0.0;
  double progress = 0.0;
  int smallBags = 0;
  int bigBags = 0;
  late Color color;
  late FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user = _auth.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool fireStoreNewItemsNeedSync = true;
  Color greyOutColor = Colors.grey.withOpacity(0.5);

  @override
  void initState() {
    super.initState();

    _searchQueryController.addListener(_onSearchChanged);
    _filteredTodos = _todos;
    getSyncBool();
    getFireStoreTodos();
    _fetchTodos();

    getAndUpdateTotalPrice(_todos);

    _getBudgetValue();
    if (mounted) {
      setState(() {
        if (totalPrice == 0.0) {
          progress = 0.0;
        } else {
          progress = totalPrice / budgetLimit;
        }
      });
    }
  }

  Future<void> _fetchTodos() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    final dbHelper = DatabaseHelper();
    final todos = await dbHelper.getAllTodos();

    // Check if Firestore fetching is needed based on the flag
    if (fireStoreNewItemsNeedSync) {
      if (user != null) {
        final firestoreSyncedTodos = await FirebaseFirestore.instance
            .collection('todos')
            .where('isSync', isEqualTo: true)
            .where('userId', isEqualTo: user?.uid)
            .get();

        final firestoreSyncedTodoIds =
            firestoreSyncedTodos.docs.map((doc) => doc['id'] as int).toList();

        final firestoreNeedsSync = firestoreSyncedTodoIds.any(
            (firestoreTodoId) =>
                !todos.any((localTodo) => localTodo.id == firestoreTodoId));

        if (mounted) {
          setState(() {
            this.fireStoreNewItemsNeedSync = firestoreNeedsSync;
          });
        }
      }
    }

    if (mounted) {
      setState(() {
        _todos = todos;
        if (user?.uid != _auth.currentUser?.uid) {
          _todos.removeWhere(
              (todo) => todo.isSync && todo.userId != _auth.currentUser?.uid);
        }

        getAllItemsSetup();
        isLoading = false;
      });
    }

    getAndUpdateTotalPrice(_todos);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final filterProvider = Provider.of<FilterItemsProvider>(context);
    final shoppingdProvider = Provider.of<ShoppingEnabledProvider>(context);
    final googlePaydProvider = Provider.of<GooglePayEnabledProvider>(context);
    final connectivityProvider = Provider.of<ConnectivityStatus>(context);
    final userSgnInProvider =
        Provider.of<UserSignInProvider>(context, listen: false);
    final bagsProvider = Provider.of<BagsProvider>(context);
    return Scaffold(
      extendBody: shoppingdProvider.geIsShoppingtEnabled ? true : false,
      backgroundColor: themeProvider.isDarkThemeEnabled
          ? Color.fromARGB(255, 39, 39, 39)
          : Colors.white,
      appBar: PreferredSize(
        preferredSize: shoppingdProvider.geIsShoppingtEnabled
            ? Size.fromHeight(kToolbarHeight + 50)
            : Size.fromHeight(kToolbarHeight),
        child: AppBar(
          iconTheme: IconThemeData(
            color:
                themeProvider.isDarkThemeEnabled ? Colors.white : Colors.black,
          ),
          backgroundColor: themeProvider.isDarkThemeEnabled
              ? const Color.fromARGB(255, 39, 39, 39)
              : Colors.white,
          elevation: 0,
          title: _isSearching
              ? _buildSearchField()
              : Row(
                  children: [
                    if (userSgnInProvider.getIsUserSignin)
                      connectivityProvider.isConnected
                          ? CircleAvatar(
                              backgroundImage:
                                  NetworkImage(user?.photoURL ?? ''),
                            )
                          : CircleAvatar(
                              backgroundColor: greyOutColor,
                            ),
                    SizedBox(
                      width: 10,
                    ),
                    userSgnInProvider.getIsUserSignin
                        ? Flexible(
                            child: Text(
                              user?.displayName ?? '',
                              style: TextStyle(
                                color: themeProvider.isDarkThemeEnabled
                                    ? connectivityProvider.isConnected
                                        ? Colors.white
                                        : Colors.grey
                                    : connectivityProvider.isConnected
                                        ? Colors.black
                                        : Colors.grey,
                              ),
                              overflow: TextOverflow
                                  .ellipsis, // or TextOverflow.fade, TextOverflow.clip, etc.
                              maxLines:
                                  1, // Set the desired maximum number of lines
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)
                                .translate('todo_title'),
                            style: TextStyle(
                                color: themeProvider.isDarkThemeEnabled
                                    ? Colors.white
                                    : Colors.black),
                          ),
                    IconButton(
                      icon: userSgnInProvider.getIsUserSignin
                          ? Icon(
                              fireStoreNewItemsNeedSync
                                  ? Icons.sync_rounded
                                  : Icons.check_circle,
                              color: fireStoreNewItemsNeedSync
                                  ? connectivityProvider.isConnected
                                      ? Colors.orange
                                      : Colors.grey
                                  : connectivityProvider.isConnected
                                      ? Colors.green
                                      : Colors.grey,
                            )
                          : Icon(
                              !userSgnInProvider.getIsUserSignin ||
                                      !connectivityProvider.isConnected
                                  ? null
                                  : Icons.circle,
                              color: !userSgnInProvider.getIsUserSignin ||
                                      !connectivityProvider.isConnected
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                      onPressed: !userSgnInProvider.getIsUserSignin
                          ? null
                          : () {
                              checkFireStore();
                            },
                    )
                  ],
                ),
          bottom: shoppingdProvider.geIsShoppingtEnabled
              ? PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight + 40),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        AppLocalizations.of(context).translate('Shopping List'),
                        style: TextStyle(fontSize: 40, color: Colors.green),
                      ),
                    ),
                  ),
                )
              : null,
          actions: _buildActions(themeProvider, filterProvider,
              shoppingdProvider, connectivityProvider),
        ),
      ),
      body: Column(
        children: [
          if (shoppingdProvider.geIsShoppingtEnabled)
            _todos.isEmpty
                ? Container()
                : AnimatedContainer(
                    curve: Curves.bounceInOut,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          allChecked(_todos)
                              ? Color.fromARGB(255, 0, 146, 139)
                              : Color.fromARGB(255, 0, 46, 44),
                          allChecked(_todos)
                              ? Color.fromARGB(255, 0, 91, 119)
                              : Color.fromARGB(255, 0, 91, 119),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.isDarkThemeEnabled
                              ? Color.fromARGB(255, 34, 31, 36).withOpacity(0.5)
                              : Color.fromARGB(255, 119, 119, 119)
                                  .withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    duration: Duration(seconds: 1),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: [
                                Icon(
                                  _todos.isEmpty
                                      ? Icons.shopping_cart
                                      : Icons.shopping_cart_checkout,
                                  color: themeProvider.isDarkThemeEnabled
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  AppLocalizations.of(context)
                                      .translate('Total Price:'),
                                  style: TextStyle(
                                    color: themeProvider.isDarkThemeEnabled
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                            TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 500),
                              tween: Tween<double>(
                                  begin: totalPrice, end: totalPrice),
                              builder: (context, value, child) {
                                return AnimatedContainer(
                                  curve: Curves.bounceIn,
                                  duration: Duration(milliseconds: 500),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    color:
                                        allChecked(_todos) && totalPrice > 0.0
                                            ? Color.fromARGB(255, 0, 146, 85)
                                            : null,
                                  ),
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    '${totalPrice.toStringAsFixed(2)}€',
                                    style: TextStyle(
                                      color: budgetLimit < totalPrice
                                          ? Colors.red
                                          : themeProvider.isDarkThemeEnabled
                                              ? Colors.white
                                              : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                        budgetLimit == 0.0
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context).translate(
                                              totalPrice > budgetLimit
                                                  ? 'You are above by:'
                                                  : 'Remaining:') +
                                          ' ${(totalPrice > budgetLimit ? totalPrice - budgetLimit : budgetLimit - totalPrice).toStringAsFixed(2)}€',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: budgetLimit > totalPrice
                                            ? const Color.fromARGB(
                                                255, 118, 139, 157)
                                            : Colors.red,
                                      ),
                                    ),
                                    SizedBox(height: 10.0), // Add some spacing
                                    Container(
                                      height: 12.0,
                                      child: LinearProgressIndicator(
                                        value: (totalPrice / budgetLimit).clamp(
                                            0.0,
                                            1.0), // Ensure the value is between 0 and 1
                                        backgroundColor: Colors
                                            .grey, // Background color of the progress bar
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          budgetLimit > totalPrice
                                              ? const Color.fromARGB(
                                                  255, 33, 243, 226)
                                              : Colors.red,
                                        ), // Color of the progress bar
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (smallBags > 0)
                              Column(
                                children: [
                                  Text(
                                    '$smallBags',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        if (mounted) {
                                          setState(() {
                                            smallBags -= 1;
                                            totalPrice -= 0.09;
                                          });
                                        }
                                      },
                                      icon: Icon(Icons.shopping_basket))
                                ],
                              ),
                            if (bigBags > 0)
                              Column(
                                children: [
                                  Text(
                                    '$bigBags',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        if (mounted) {
                                          setState(() {
                                            bigBags -= 1;
                                            totalPrice -= 0.18;
                                          });
                                        }
                                      },
                                      icon: Icon(
                                        Icons.shopping_basket,
                                        size: 32,
                                      ))
                                ],
                              )
                          ],
                        )
                      ],
                    ),
                  ),
          isLoading
              ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        themeProvider.isDarkThemeEnabled
                            ? Color.fromARGB(255, 131, 175, 197)
                            : Colors.blueGrey,
                      ),
                      strokeWidth: 5.0, // Replace with your desired value
                    ),
                  ),
                )
              : Expanded(
                  child: RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: _fetchTodos,
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                          bottom: kFloatingActionButtonMargin + 50),
                      itemCount: _isSearching || isListviewFiltered
                          ? _filteredTodos.length
                          : _todos.length,
                      itemBuilder: (context, index) {
                        final todo = _isSearching || isListviewFiltered
                            ? _filteredTodos[index]
                            : _todos[index];

                        titleText = todo.title;

                        return Dismissible(
                          key: Key(todo.id.toString()),
                          onDismissed: (direction) async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            // Remove the item from the data source.
                            if (mounted) {
                              setState(() {
                                _todos.removeAt(index);
                                final dbHelper = DatabaseHelper();
                                dbHelper.delete(todo.id ?? 0);

                                if (todo.isSync) {
                                  fireStoreNewItemsNeedSync = true;
                                  prefs.setBool('fireStoreNewItemsNeedSync',
                                      fireStoreNewItemsNeedSync);
                                }
                              });
                            }

                            // Show a snackbar with the undo option.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(context).translate(
                                          shoppingdProvider.isSoppingEnabled
                                              ? 'Shopping Item deleted'
                                              : 'Todo deleted') +
                                      ' ' +
                                      todo.title,
                                ),
                                action: SnackBarAction(
                                  label: AppLocalizations.of(context)
                                      .translate('Undo'),
                                  onPressed: () {
                                    if (mounted) {
                                      setState(() {
                                        _todos.add(todo);
                                      });
                                      final dbHelper = DatabaseHelper();
                                      dbHelper.insert(todo);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                          background: Container(
                            color: Colors.red,
                            child: Icon(Icons.delete, color: Colors.white),
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 16),
                          ),
                          child: Padding(
                            key: ValueKey(todo.id),
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: todo.isDone
                                          ? Colors.green
                                          : shoppingdProvider.isSoppingEnabled
                                              ? const Color.fromARGB(
                                                  255, 46, 60, 67)
                                              : getPriorityColor(todo.priority),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: ListTile(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(titleText,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: todo.isDone
                                                  ? const TextStyle(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      color: Colors.grey)
                                                  : null),
                                        ),
                                        if (todo.isSync)
                                          Icon(
                                            Icons.check_circle,
                                            color: todo.isSync
                                                ? Colors.green
                                                : null,
                                          ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        if (todo.description.isNotEmpty)
                                          Icon(
                                            Icons.article_outlined,
                                            size: 20,
                                            color: Colors.green,
                                          ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                    trailing: CustomCheckbox(
                                      isChecked: todo.isDone,
                                      onChanged: (value) {
                                        if (mounted) {
                                          setState(() {
                                            if (value == true) {
                                              totalPrice +=
                                                  todo.totalProductPrice;
                                            } else {
                                              totalPrice -=
                                                  todo.totalProductPrice;
                                            }

                                            todo.isDone = value!;

                                            final newtodo = Todo(
                                              id: todo.id,
                                              title: todo.title,
                                              isDone: value,
                                              description: todo.description,
                                              isShopping: todo.isShopping,
                                              quantity: todo.quantity,
                                              productPrice: todo.productPrice,
                                              totalProductPrice:
                                                  todo.totalProductPrice,
                                              isHourSelected:
                                                  todo.isHourSelected,
                                              dueDate: todo.dueDate,
                                              priority: todo.priority,
                                              lastUpdated: todo.lastUpdated,
                                              isSync: false,
                                              userId: todo.userId,
                                              selectedTimeHour:
                                                  todo.selectedTimeHour,
                                              selectedTimeMinute:
                                                  todo.selectedTimeMinute,
                                              isForTodo: todo.isForTodo,
                                              isForShopping: todo.isForShopping,
                                            );

                                            dbHelper.update(newtodo);
                                            checkedTodosCounT =
                                                getCheckedTodosCount(_todos);
                                          });
                                        }
                                      },
                                    ),
                                    onTap: () {
                                      _navigateToEditScreen(context, todo,
                                          _todos, index, isForEdit);
                                    },
                                    subtitle: todo.totalProductPrice == 0
                                        ? null
                                        : shoppingdProvider.geIsShoppingtEnabled
                                            ? todo.totalProductPrice == 0.0
                                                ? Container()
                                                : Row(
                                                    children: [
                                                      todo.isDone
                                                          ? Container()
                                                          : Container(
                                                              width: 20,
                                                              height: 20,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .green,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .shopping_bag,
                                                                color: Colors
                                                                    .white,
                                                                size: 12,
                                                              ),
                                                            ),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        '\E${todo.totalProductPrice.toStringAsFixed(2)}',
                                                        style: todo.isDone
                                                            ? const TextStyle(
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                                color:
                                                                    Colors.grey)
                                                            : null,
                                                      ),
                                                    ],
                                                  )
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
          if (!shoppingdProvider.geIsShoppingtEnabled && _todos.length >= 1)
            allChecked(_todos)
                ? AnimatedContainer(
                    curve: Curves.bounceInOut,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: allChecked(_todos)
                            ? [
                                Color.fromARGB(255, 39, 40, 41),
                                Color.fromARGB(255, 58, 99, 187),
                              ]
                            : [Colors.transparent, Colors.transparent],
                      ),
                      borderRadius: allChecked(_todos)
                          ? BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                            )
                          : BorderRadius.zero,
                      boxShadow: allChecked(_todos)
                          ? [
                              BoxShadow(
                                color: themeProvider.isDarkThemeEnabled
                                    ? Color.fromARGB(255, 46, 46, 46)
                                        .withOpacity(0.5)
                                    : Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset: Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    duration: Duration(seconds: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('All items are checked!'),
                              style: TextStyle(
                                color: themeProvider.isDarkThemeEnabled
                                    ? Colors.white
                                    : Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                        TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 500),
                          tween:
                              Tween<double>(begin: totalPrice, end: totalPrice),
                          builder: (context, value, child) {
                            return AnimatedContainer(
                              curve: Curves.bounceIn,
                              duration: Duration(milliseconds: 500),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: allChecked(_todos)
                                    ? Color.fromARGB(255, 60, 62, 97)
                                    : null,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                              ),
                              padding: EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.check_box_sharp,
                                color: Colors.white,
                                size: 24.0,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                : Container(),
          Visibility(
            visible: shoppingdProvider.geIsShoppingtEnabled &&
                _todos.length >= 1 &&
                allChecked(_todos),
            child: AnimatedContainer(
              height: shoppingdProvider.geIsShoppingtEnabled &&
                      _todos.length >= 1 &&
                      allChecked(_todos)
                  ? bagsProvider.isBagsProviderEnabled
                      ? 310.0
                      : 150
                  : 0.0,
              duration: Duration(seconds: 5),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                ),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.0),
                      MaterialButton(
                        onPressed: () {
                          if (allChecked(_todos) &&
                              shoppingdProvider.geIsShoppingtEnabled) {
                            // Create a list of todo IDs to upload
                            List<int?> todoIdsToUpload =
                                _todos.map((todo) => todo.id).toList();
                            uploadListToFirestoreForHistory(todoIdsToUpload);
                          }
                          _navigateToCheckoutPage(
                              shoppingdProvider, googlePaydProvider);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(color: Colors.blueGrey.shade100),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_checkout_rounded,
                              color: Colors.black,
                              size: 30,
                            ),
                            SizedBox(width: 16.0),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('Complete Transaction'),
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      if (bagsProvider.isBagsProviderEnabled)
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 400,
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 78, 76, 175),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                textAlign: TextAlign.center,
                                AppLocalizations.of(context)
                                    .translate('Bought any Supermarket Bags ?'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (bagsProvider.isBagsProviderEnabled)
                        SizedBox(
                          height: 20,
                        ),
                      if (bagsProvider.isBagsProviderEnabled)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 100,
                              width: 100,
                              child: MaterialButton(
                                color: smallBags > 0
                                    ? Colors.green
                                    : const Color.fromARGB(255, 175, 76, 101),
                                onPressed: () {
                                  if (mounted) {
                                    setState(() {
                                      totalPrice += 0.09;
                                      smallBags += 1;
                                    });
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Adjust the radius as needed
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      textAlign: TextAlign.center,
                                      AppLocalizations.of(context)
                                          .translate('Small supermarket bag'),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(textAlign: TextAlign.center, '9 ΛΕΠΤΑ')
                                  ],
                                ),
                              ),
                            ),
                            if (bagsProvider.isBagsProviderEnabled)
                              SizedBox(
                                height: 100,
                                width: 100,
                                child: MaterialButton(
                                  color: bigBags > 0
                                      ? Colors.green
                                      : const Color.fromARGB(255, 175, 76, 101),
                                  onPressed: () {
                                    if (mounted) {
                                      setState(() {
                                        totalPrice += 0.18;
                                        bigBags += 1;
                                      });
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Adjust the radius as needed
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        textAlign: TextAlign.center,
                                        AppLocalizations.of(context)
                                            .translate('Big supermarket bag'),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                          textAlign: TextAlign.center,
                                          '18 ΛΕΠΤΑ')
                                    ],
                                  ),
                                ),
                              )
                          ],
                        )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: Theme(
        data: ThemeData(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                secondary: themeProvider.isDarkThemeEnabled
                    ? const Color.fromARGB(255, 93, 122, 133)
                    : Colors.blueGrey[800], // Change the color of the FAB
              ),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Padding(
          padding: EdgeInsets.only(
              bottom: allChecked(_todos) &&
                      !shoppingdProvider.geIsShoppingtEnabled &&
                      _todos.length >= 1
                  ? 70
                  : allChecked(_todos) &&
                          shoppingdProvider.geIsShoppingtEnabled &&
                          _todos.length >= 1 &&
                          googlePaydProvider.geIsGooglePaytEnabled
                      ? bagsProvider.isBagsProviderEnabled
                          ? 320
                          : 100
                      : 0),
          child: FloatingActionButton(
            highlightElevation: 3.0,
            onPressed: () {
              _navigateToAddScreen(context, isForEdit);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(shoppingdProvider.geIsShoppingtEnabled
                ? Icons.add_shopping_cart
                : IconlyLight.plus),
          ),
        ),
      ),
      floatingActionButtonLocation: shoppingdProvider.geIsShoppingtEnabled
          ? FloatingActionButtonLocation.endFloat
          : allChecked(_todos) && _todos.length >= 1
              ? FloatingActionButtonLocation.miniEndFloat
              : FloatingActionButtonLocation.centerFloat,
    );
  }

  void _navigateToAddScreen(BuildContext context, bool isForEdit) {
    DateTime now = DateTime.now();
    final newTodo = Todo(
      isDone: false,
      title: '',
      description: '',
      isShopping: false,
      quantity: 0,
      productPrice: 0.0,
      totalProductPrice: 0.0,
      isHourSelected: false,
      dueDate: now.toIso8601String(),
      priority: 0,
      lastUpdated: now.toIso8601String(),
      isSync: false,
      userId: '',
      selectedTimeHour: 0,
      selectedTimeMinute: 0,
      isForTodo: false,
      isForShopping: false,
    );

    Navigator.of(context)
        .push(
      CustomPageRoute(
        child: AddEditTodoScreen(
            todo: newTodo,
            fetchFunction: _fetchTodos,
            isForEdit: false,
            changePriceFunction: getAndUpdateTotalPrice,
            listTodos: _todos),
        forwardAnimation: true,
        duration: Duration(milliseconds: 700),
      ),
    )
        .then((value) {
      if (value == true) {
        _fetchTodos();
      }
    });
  }

  void _navigateToEditScreen(BuildContext context, Todo todo, List<Todo> todos,
      int index, bool isForEdit) {
    Navigator.of(context)
        .push(
      CustomPageRoute(
        child: AddEditTodoScreen(
            todo: todo,
            fetchFunction: _fetchTodos,
            isForEdit: true,
            changePriceFunction: getAndUpdateTotalPrice,
            listTodos: _todos),
        forwardAnimation: true,
        duration: Duration(milliseconds: 700),
      ),
    )
        .then((value) {
      if (value == true) {
        _fetchTodos();
      }
    });
  }

  void _navigateToSettingsScreen(BuildContext context, List<Todo> todos) {
    final userSgnInProvider =
        Provider.of<UserSignInProvider>(context, listen: false);
    Navigator.of(context).push(
      CustomPageRoute(
        child: SettingsPage(
          itemsChecked: checkedTodosCounT,
          listTodos: todos,
          isUserSignIn: userSgnInProvider.getIsUserSignin,
        ),
        forwardAnimation: true,
        duration: Duration(milliseconds: 700),
      ),
    );
  }

  int getCheckedTodosCount(List<Todo> todos) {
    return todos.where((todo) => todo.isDone).length;
  }

  int getCheckedShoppingCount(List<Todo> todos) {
    return todos.where((todo) => todo.isDone && todo.isShopping).length;
  }

  List<Widget> _buildActions(
      ThemeProvider themeProvider,
      FilterItemsProvider filterProvider,
      ShoppingEnabledProvider shoppingdProvider,
      ConnectivityStatus connectivityProvider) {
    if (_isSearching) {
      return [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            if (mounted) {
              setState(() {
                _searchQueryController.clear();
                searchQuery = "";
                _isSearching = false;
              });
            }
          },
        )
      ];
    } else {
      bool allItemsNotChecked = _todos.every((element) => !element.isDone);
      bool allItemsChecked = _todos.every((element) => element.isDone);
      return [
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: isListviewFiltered
                ? Color.fromARGB(255, 0, 174, 255)
                : _todos.length == 1 || allItemsNotChecked || allItemsChecked
                    ? Colors.grey
                    : themeProvider.isDarkThemeEnabled
                        ? Colors.white
                        : Colors.black,
          ),
          onPressed: _todos.length == 1 || allItemsNotChecked || allItemsChecked
              ? null
              : () {
                  if (mounted) {
                    setState(() {
                      isListviewFiltered = !isListviewFiltered;
                      setState(() {
                        if (filterProvider.showCheckedItems) {
                          _filteredTodos =
                              _todos.where((todo) => !todo.isDone).toList();
                        } else {
                          _filteredTodos =
                              _todos.where((todo) => todo.isDone).toList();
                        }
                        if (!filterProvider.showCheckedItems) {
                          _filteredTodos =
                              _todos.where((todo) => !todo.isDone).toList();
                        } else {
                          _filteredTodos =
                              _todos.where((todo) => todo.isDone).toList();
                        }
                      });
                    });
                  }
                },
        ),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: _todos.isEmpty || _todos.length < 4
              ? null
              : () {
                  if (mounted) {
                    setState(() {
                      _isSearching = true;
                    });
                  }
                },
        ),
        IconButton(
            onPressed: () {
              _navigateToSettingsScreen(context, _todos);
            },
            icon: const Icon(IconlyLight.setting))
      ];
    }
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).translate('Search...'),
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white54),
      ),
      style: TextStyle(color: Colors.black, fontSize: 16.0),
      onChanged: (query) {
        if (mounted) {
          setState(() {
            _onSearchChanged();
          });
        }
      },
    );
  }

  void _onSearchChanged() {
    final searchQuery = _searchQueryController.text;
    if (mounted) {
      setState(() {
        _filteredTodos = _todos
            .where((todo) =>
                todo.title.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      });
    }
  }

  void getAllItemsSetup() {
    final shoppingdProvider =
        Provider.of<ShoppingEnabledProvider>(context, listen: false);

    if (shoppingdProvider.geIsShoppingtEnabled) {
      if (mounted) {
        setState(() {
          _todos.removeWhere((element) => !element.isShopping);
          checkedTodosCounT = getCheckedShoppingCount(_todos);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _todos.removeWhere((element) => element.isShopping);
          checkedTodosCounT = getCheckedTodosCount(_todos);
        });
      }
    }
  }

  void showExitsSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).translate('Already Exists')),
      ),
    );
  }

  bool allChecked(List<Todo> todos) {
    for (var todo in todos) {
      if (!todo.isDone) {
        return false;
      }
    }
    return true;
  }

  getAndUpdateTotalPrice(List<Todo> todos) async {
    for (Todo todo in _todos) {
      if (todo.isDone) {
        if (mounted) {
          setState(() {
            totalPrice = 0.0;
            double sum = _todos.fold(
                0.0,
                (acc, todo) =>
                    todo.isDone ? acc + todo.totalProductPrice : acc);

            totalPrice = sum;
          });
        }
      } else if (allChecked(_todos)) {
        if (mounted) {}
        if (mounted) {
          setState(() {
            totalPrice = 0.0;
          });
        }
      }
    }
  }

  void _getBudgetValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        budgetLimit = prefs.getDouble(
              'budgetValue',
            ) ??
            0;
      });
    }
  }

  String priorityToString(int priority) {
    switch (priority) {
      case 0:
        return AppLocalizations.of(context).translate('Low');
      case 1:
        return AppLocalizations.of(context).translate('Medium');
      case 2:
        return AppLocalizations.of(context).translate('High');
      default:
        return '';
    }
  }

  getPriorityColor(int priority) {
    switch (priority) {
      case 2:
        return Colors.red;
      case 1:
        return Color.fromARGB(255, 226, 128, 16);
      case 0:
        return Colors.green;
    }
  }

  void getSyncBool() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool valueBool = prefs.getBool('fireStoreNewItemsNeedSync') ?? true;
    if (mounted) {
      setState(() {
        fireStoreNewItemsNeedSync = valueBool;
      });
    }
  }

  void getFireStoreTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final syncedTodos = await dbHelper.getSyncedTodos();
    int savedFireStoreCount = prefs.getInt('firestoreCount') ?? 0;
    final syncedTodoCount = syncedTodos.length;
    if (savedFireStoreCount > syncedTodoCount) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('todos')
          .where('isSync', isEqualTo: true)
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .get();
      final count = querySnapshot.docs.length;

      prefs.setInt('firestoreCount', count);
      if (mounted) {
        setState(() {
          fireStoreNewItemsNeedSync = false;
        });
      }

      prefs.setBool('fireStoreNewItemsNeedSync', fireStoreNewItemsNeedSync);
      // Remove synced items that do not belong to the current user
    }
  }

  void checkFireStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final syncedTodoDocs = await FirebaseFirestore.instance
        .collection('todos')
        .where('isSync', isEqualTo: true)
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .get();

    final syncedTodoData =
        syncedTodoDocs.docs.map((doc) => doc.data()).toList();

// Save synced todos to local database
    for (final data in syncedTodoData) {
      final fireStoreTodo = Todo.fromFireStore(data);

      bool shoppingItemExists = false;
      dbHelper.checkIfShoppingItemExists(fireStoreTodo).then((value) {
        if (mounted) {
          setState(() {
            shoppingItemExists = value;
          });
        }
      });
      bool todoItemListExists = false;
      dbHelper.checkIfTodoItemExists(fireStoreTodo).then((value) {
        if (mounted) {
          setState(() {
            todoItemListExists = value;
          });
        }
      });

      final newtodo = Todo(
        id: fireStoreTodo.id,
        title: fireStoreTodo.title,
        isDone: fireStoreTodo.isDone,
        description: fireStoreTodo.description,
        isShopping: fireStoreTodo.isShopping,
        quantity: fireStoreTodo.quantity,
        productPrice: fireStoreTodo.productPrice,
        totalProductPrice: fireStoreTodo.totalProductPrice,
        isHourSelected: fireStoreTodo.isHourSelected,
        dueDate: fireStoreTodo.dueDate,
        priority: fireStoreTodo.priority,
        lastUpdated: fireStoreTodo.lastUpdated,
        isSync: fireStoreTodo.isSync,
        userId: fireStoreTodo.userId,
        selectedTimeHour: fireStoreTodo.selectedTimeHour,
        selectedTimeMinute: fireStoreTodo.selectedTimeMinute,
        isForTodo: fireStoreTodo.isForTodo,
        isForShopping: fireStoreTodo.isForShopping,
      );

      if (!shoppingItemExists || !todoItemListExists) {
        await dbHelper.insert(newtodo);
        if (mounted) {
          setState(() {
            fireStoreNewItemsNeedSync = false;
          });
        }

        _fetchTodos();
        prefs.setBool('fireStoreNewItemsNeedSync', fireStoreNewItemsNeedSync);
      }
    }
  }

  void uploadListToFirestoreForHistory(List<int?> todoIds) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String valueUserId = prefs.getString('userId') ?? '';
    final dbHelper = DatabaseHelper();

    for (int? id in todoIds) {
      final todo = await dbHelper.getTodoById(id);

      if (todo != null) {
        DocumentReference docRef =
            firestore.collection('todo_history').doc(todo.id.toString());

        // Document doesn't exist, create a new one
        await docRef.set({
          'id': todo.id,
          'docRefId': todo.id,
          'title': todo.title,
          'isDone': todo.isDone,
          'description': todo.description,
          'isShopping': todo.isShopping,
          'quantity': todo.quantity,
          'productPrice': todo.productPrice,
          'totalProductPrice': todo.totalProductPrice,
          'isHourSelected': todo.isHourSelected,
          'dueDate': todo.dueDate,
          'priority': todo.priority,
          'lastUpdated': todo.lastUpdated,
          'isSync': todo.isSync,
          'userId': valueUserId,
          'isForTodo': todo.isForTodo,
          'isForShopping': todo.isForShopping,
          'date': DateTime.now(),
          'totalPrice': totalPrice,
        });
      }
    }
  }

  void _navigateToCheckoutPage(ShoppingEnabledProvider shoppingdProvider,
      GooglePayEnabledProvider googlePaydProvider) {
    Navigator.of(context).push(
      CustomPageRoute(
        child: CheckoutPage(
            itemsChecked: allChecked(_todos),
            totalPrice: totalPrice,
            shoppingdProvider: shoppingdProvider,
            googlePaydProvider: googlePaydProvider),
        forwardAnimation: true,
        duration: Duration(milliseconds: 500),
      ),
    );
  }
}
