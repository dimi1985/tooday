// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooday/models/todo.dart';
import 'package:tooday/screens/add_edit_todo_screen.dart';
import 'package:tooday/screens/settings_screen.dart';
import 'package:tooday/utils/app_localization.dart';
import 'package:tooday/widgets/custom_check_box.dart';
import 'package:tooday/widgets/custom_page_route.dart';
import 'package:tooday/widgets/filterItemsProvider.dart';
import 'package:tooday/widgets/shopping_enabled_provider.dart';
import 'package:tooday/widgets/theme_provider.dart';
import '../database/database_helper.dart';
import 'package:iconly/iconly.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();

  static Future<List<Todo>> getList() async {
    final dbHelper = DatabaseHelper();
    final todos = await dbHelper.getAllTodos();
    return todos;
  }
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
  late Color color;
  @override
  void initState() {
    super.initState();
    _searchQueryController.addListener(_onSearchChanged);
    _filteredTodos = _todos;
    _fetchTodos();
    getAndUpdateTotalPrice(_todos);
    _getBudgetValue();
    setState(() {
      if (totalPrice == 0.0) {
        progress = 0.0;
      } else {
        progress = totalPrice / budgetLimit;
      }
    });
  }

  Future<void> _fetchTodos() async {
    setState(() {
      isLoading = true;
    });
    final dbHelper = DatabaseHelper();
    final todos = await dbHelper.getAllTodos();

    setState(() {
      _todos = todos;

      getAllItemsSetup();
      isLoading = false;
    });

    getAndUpdateTotalPrice(_todos);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final filterProvider = Provider.of<FilterItemsProvider>(context);
    final shoppingdProvider = Provider.of<ShoppingEnabledProvider>(context);

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
              : Text(
                  AppLocalizations.of(context).translate('todo_title'),
                  style: TextStyle(
                      color: themeProvider.isDarkThemeEnabled
                          ? Colors.white
                          : Colors.black),
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
          actions:
              _buildActions(themeProvider, filterProvider, shoppingdProvider),
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
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  AppLocalizations.of(context)
                                      .translate('Total Price:'),
                                  style: TextStyle(
                                    color: Colors.white,
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
                                      color: Colors.white,
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
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    AppLocalizations.of(context).translate(
                                            totalPrice > budgetLimit
                                                ? 'You are above by:'
                                                : 'Remaining:') +
                                        ' ${(totalPrice > budgetLimit ? totalPrice - budgetLimit : budgetLimit - totalPrice).toStringAsFixed(2)}€',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: budgetLimit > totalPrice
                                          ? Colors.blue
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ),
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
              : _todos.isEmpty
                  ? Expanded(
                      child: Container(
                        color: themeProvider.isDarkThemeEnabled
                            ? Color.fromARGB(255, 39, 39, 39)
                            : Colors.white, // Change background color here
                        child: Center(
                            child: Text(AppLocalizations.of(context)
                                .translate('List is appears Empty'))),
                      ),
                    )
                  // _refreshIndicatorKey
                  : Expanded(
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

                          return Padding(
                            key: ValueKey(todo.id),
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: todo.isDone
                                          ? Colors.green
                                          : Colors.grey,
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
                                        if (todo.description.isNotEmpty)
                                          Icon(
                                            Icons.article_outlined,
                                            size: 16,
                                            color: Color.fromARGB(
                                                255, 58, 137, 183),
                                          ),
                                        SizedBox(
                                          width: 5,
                                        ),
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
                                        !shoppingdProvider.geIsShoppingtEnabled
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: todo.isDone
                                                      ? Colors.grey
                                                      : getPriorityColor(
                                                          todo.priority),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                child: Text(
                                                  priorityToString(
                                                      todo.priority),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                    trailing: CustomCheckbox(
                                      isChecked: todo.isDone,
                                      onChanged: (value) {
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
                                            entryDate: todo.entryDate,
                                            dueDate: todo.dueDate,
                                            priority: todo.priority,
                                          );

                                          dbHelper.update(newtodo);
                                          checkedTodosCounT =
                                              getCheckedTodosCount(_todos);
                                        });
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
                          );
                        },
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
                                    ? Color.fromARGB(255, 34, 31, 36)
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
      entryDate: now.toIso8601String(),
      dueDate: now.toIso8601String(),
      priority: 0,
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
    Navigator.of(context)
        .push(
      CustomPageRoute(
        child: SettingsPage(itemsChecked: checkedTodosCounT, listTodos: todos),
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

  int getCheckedTodosCount(List<Todo> todos) {
    return todos.where((todo) => todo.isDone).length;
  }

  int getCheckedShoppingCount(List<Todo> todos) {
    return todos.where((todo) => todo.isDone && todo.isShopping).length;
  }

  List<Widget> _buildActions(
      ThemeProvider themeProvider,
      FilterItemsProvider filterProvider,
      ShoppingEnabledProvider shoppingdProvider) {
    if (_isSearching) {
      return [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _searchQueryController.clear();
              searchQuery = "";
              _isSearching = false;
            });
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
                },
        ),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: _todos.isEmpty || _todos.length < 4
              ? null
              : () {
                  setState(() {
                    _isSearching = true;
                  });
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
        setState(() {
          _onSearchChanged();
        });
      },
    );
  }

  void _onSearchChanged() {
    final searchQuery = _searchQueryController.text;
    setState(() {
      _filteredTodos = _todos
          .where((todo) =>
              todo.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  void getAllItemsSetup() {
    final shoppingdProvider =
        Provider.of<ShoppingEnabledProvider>(context, listen: false);

    if (shoppingdProvider.geIsShoppingtEnabled) {
      setState(() {
        _todos.removeWhere((element) => !element.isShopping);
        checkedTodosCounT = getCheckedShoppingCount(_todos);
      });
    } else {
      setState(() {
        _todos.removeWhere((element) => element.isShopping);
        checkedTodosCounT = getCheckedTodosCount(_todos);
      });
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
        setState(() {
          totalPrice = 0.0;
          double sum = _todos.fold(0.0,
              (acc, todo) => todo.isDone ? acc + todo.totalProductPrice : acc);

          totalPrice = sum;
        });
      } else if (allChecked(_todos)) {
        setState(() {
          totalPrice = 0.0;
        });
      }
    }
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
        return Colors.yellow;
      case 0:
        return Colors.green;
    }
  }
}
