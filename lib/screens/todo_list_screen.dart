// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooday/models/todo.dart';
import 'package:tooday/screens/add_edit_todo_screen.dart';
import 'package:tooday/screens/settings_screen.dart';
import 'package:tooday/utils/app_localization.dart';
import 'package:tooday/widgets/custom_check_box.dart';
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
  bool isOverflowed = false;
  bool isListviewFiltered = false;
  TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = "";
  String titleText = "";
  List<Todo> _filteredTodos = [];
  double totalPrice = 0.0;
  bool isKeyboardOpened = false;
  @override
  void initState() {
    super.initState();
    _searchQueryController.addListener(_onSearchChanged);
    _filteredTodos = _todos;
    _fetchTodos();
    getTotalPrice();
  }

  Future<void> _fetchTodos() async {
    setState(() {
      isLoading = true;
    });
    final dbHelper = DatabaseHelper();
    final todos = await dbHelper.getAllTodos();

    setState(() {
      _todos = todos;

      checkedTodosCounT = getCheckedTodosCount(_todos);
      getAllItemsSetup();
      isLoading = false;
    });
    loadOrder();
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
          actions: _buildActions(themeProvider, filterProvider),
        ),
      ),
      body: Column(
        children: [
          if (shoppingdProvider.geIsShoppingtEnabled)
            _todos.isEmpty
                ? Container()
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context)
                                  .translate('Total Price: ') +
                              '\$${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      themeProvider.isDarkThemeEnabled
                          ? Color.fromARGB(255, 131, 175, 197)
                          : Colors.blueGrey,
                    ),
                    strokeWidth: 5.0, // Replace with your desired value
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
                      child: ReorderableListView(
                        onReorder: (int oldIndex, int newIndex) {
                          reOrderTodoList(newIndex, oldIndex);
                        },
                        children: List.generate(
                          _isSearching || isListviewFiltered
                              ? _filteredTodos.length
                              : _todos.length,
                          (index) {
                            final todo = _isSearching || isListviewFiltered
                                ? _filteredTodos[index]
                                : _todos[index];

                            titleText = todo.title;
                            bool isOverflowed =
                                isTextOverflowed(titleText, context);

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
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        color: Colors.grey)
                                                    : null),
                                          ),
                                        ],
                                      ),
                                      trailing: CustomCheckbox(
                                        isChecked: todo.isDone,
                                        onChanged: (value) {
                                          setState(() {
                                            if (value == true) {
                                              totalPrice +=
                                                  todo.totalProductPrice;
                                              saveTotalPrice(totalPrice);
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
                                              totalPrice: totalPrice,
                                            );

                                            dbHelper.update(newtodo);
                                            checkedTodosCounT =
                                                getCheckedTodosCount(_todos);
                                          });
                                        },
                                      ),
                                      onTap: () {
                                        if (shoppingdProvider
                                            .geIsShoppingtEnabled) {
                                          if (todo.isDone) {
                                            setState(() {});
                                            return;
                                          } else {
                                            showDescriptionSheet(todo, index,
                                                titleText, shoppingdProvider);
                                          }
                                        } else {
                                          if (todo.description.isNotEmpty ||
                                              isOverflowed) {
                                            showDescriptionSheet(todo, index,
                                                titleText, shoppingdProvider);
                                          } else {
                                            _navigateToEditScreen(
                                                context, todo, _todos, index);
                                          }
                                        }
                                      },
                                      subtitle: shoppingdProvider
                                              .geIsShoppingtEnabled
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
                                                              color:
                                                                  Colors.green,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .shopping_bag,
                                                              color:
                                                                  Colors.white,
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
                    ),
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
        child: FloatingActionButton(
          highlightElevation: 3.0,
          onPressed: () {
            _navigateToAddScreen(context);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(shoppingdProvider.geIsShoppingtEnabled
              ? Icons.add_shopping_cart
              : IconlyLight.plus),
        ),
      ),
      floatingActionButtonLocation: shoppingdProvider.geIsShoppingtEnabled
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerFloat,
    );
  }

  void _navigateToAddScreen(BuildContext context) {
    final newTodo = Todo(
        isDone: false,
        title: '',
        description: '',
        isShopping: false,
        quantity: 0,
        productPrice: 0.0,
        totalProductPrice: 0.0,
        totalPrice: 0.0);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTodoScreen(
          todo: newTodo,
          fetchFunction: _fetchTodos,
        ),
      ),
    ).then((value) {
      if (value == true) {
        _fetchTodos();
      }
    });
  }

  showDescriptionSheet(Todo todo, int index, String textWidget,
      ShoppingEnabledProvider shoppingdProvider) {
    int modalQuantity = 1;
    double productPrice = 0.0;
    double totalProductPrice = modalQuantity * productPrice;
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        print(isKeyboardOpened);
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 3,
                          height: 4,
                          color: shoppingdProvider.geIsShoppingtEnabled
                              ? Colors.greenAccent
                              : Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate('Details'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _navigateToEditScreen(
                                  context, todo, _todos, index);
                              setState(() {
                                Navigator.canPop(context);
                              });
                            },
                            icon: Icon(
                              Icons.edit,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        todo.title.isEmpty
                            ? AppLocalizations.of(context).translate(
                                'No Title',
                              )
                            : todo.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        todo.description.isEmpty
                            ? AppLocalizations.of(context).translate(
                                'No Description',
                              )
                            : todo.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            shoppingdProvider.geIsShoppingtEnabled
                                ? 'Quantity'
                                : 'Date',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          shoppingdProvider.geIsShoppingtEnabled
                              ? SizedBox(
                                  height: 50,
                                  width: 70,
                                  child: TextFormField(
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: todo.quantity.toString(),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        modalQuantity = value.isEmpty
                                            ? todo.quantity
                                            : int.parse(value);
                                        totalProductPrice =
                                            modalQuantity * productPrice;

                                        final newTodo = Todo(
                                          id: todo.id,
                                          title: todo.title,
                                          isDone: todo.isDone,
                                          description: todo.description,
                                          isShopping: todo.isShopping,
                                          quantity: modalQuantity,
                                          productPrice: productPrice,
                                          totalProductPrice: totalProductPrice,
                                          totalPrice: todo.totalPrice,
                                        );

                                        dbHelper.update(newTodo);
                                      });
                                    },
                                  ),
                                )
                              : Text(
                                  'Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            shoppingdProvider.geIsShoppingtEnabled
                                ? 'Price'
                                : 'Priority',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          shoppingdProvider.geIsShoppingtEnabled
                              ? SizedBox(
                                  height: 50,
                                  width: 70,
                                  child: TextFormField(
                                    textInputAction: TextInputAction.done,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: InputDecoration(
                                      labelText: todo.productPrice.toString(),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        productPrice = value.isEmpty
                                            ? todo.productPrice
                                            : double.tryParse(value.replaceAll(
                                                    ',', '.')) ??
                                                todo.productPrice;
                                        totalProductPrice =
                                            modalQuantity * productPrice;

                                        final newTodo = Todo(
                                          id: todo.id,
                                          title: todo.title,
                                          isDone: todo.isDone,
                                          description: todo.description,
                                          isShopping: todo.isShopping,
                                          quantity: modalQuantity,
                                          productPrice: productPrice,
                                          totalProductPrice: totalProductPrice,
                                          totalPrice: 0.0,
                                        );

                                        dbHelper.update(newTodo);
                                      });
                                    },
                                  ),
                                )
                              : Text(
                                  'Priority',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                        ],
                      ),
                      if (shoppingdProvider.geIsShoppingtEnabled)
                        SizedBox(
                          height: 25,
                        ),
                      if (shoppingdProvider.geIsShoppingtEnabled)
                        Text(
                          'Total Price: \E${totalProductPrice == 0 ? todo.totalProductPrice : totalProductPrice}',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        );
      },
    ).whenComplete(() => {
          _fetchTodos(),
        });
  }

  bool isTextOverflowed(String text, BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(text: text),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: MediaQuery.of(context).size.width);

    return textPainter.didExceedMaxLines;
  }

  void _navigateToEditScreen(
      BuildContext context, Todo todo, List<Todo> todos, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTodoScreen(
          todo: todo,
          fetchFunction: _fetchTodos,
        ),
      ),
    ).then((value) {
      if (value == true) {
        _fetchTodos();
      }
    });
  }

  void _navigateToSettingsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(),
      ),
    ).then((value) {
      if (value == true) {
        _fetchTodos();
      }
    });
  }

  int getCheckedTodosCount(List<Todo> todos) {
    return todos.where((todo) => todo.isDone).length;
  }

  void saveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final order = _todos.map((todo) => todo.id.toString()).toList();
    await prefs.setStringList('todo_order', order);
  }

  void loadOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final order = prefs.getStringList('todo_order');
    if (order != null) {
      setState(() {
        _todos.sort((a, b) =>
            order.indexOf(a.id.toString()) - order.indexOf(b.id.toString()));
      });
    }
  }

  void reOrderTodoList(int newIndex, int oldIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _todos.removeAt(oldIndex);
      _todos.insert(newIndex, item);
      saveOrder();
    });
  }

  List<Widget> _buildActions(
      ThemeProvider themeProvider, FilterItemsProvider filterProvider) {
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
          icon: PopupMenuButton(
            icon: const Icon(IconlyLight.more_square),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'Settings',
                  child:
                      Text(AppLocalizations.of(context).translate('Settings')),
                ),
                PopupMenuItem(
                  value: 'Clear Data',
                  child: Text(
                      AppLocalizations.of(context).translate('Clear Data')),
                ),
                PopupMenuItem(
                  value: 'Clear Selected',
                  child: Text(
                      AppLocalizations.of(context).translate('Clear Selected') +
                          ':($checkedTodosCounT)'),
                ),
              ];
            },
            onSelected: (value) {
              switch (value) {
                case 'Settings':
                  // Handle Settings action
                  _navigateToSettingsScreen(context);
                  break;
                case 'Clear Data':
                  // Handle Clear Data action

                  dbHelper.deleteAll();
                  clearTotalPrice();
                  _fetchTodos();

                  break;
                case 'Clear Selected':
                  // Handle Clear Selected action
                  _todos.removeWhere((todo) => todo.isDone);

                  dbHelper.deleteDoneTodos();
                  clearTotalPrice();
                  _fetchTodos();
                  break;
              }
            },
          ),
          onPressed: () {},
        ),
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
      });
    } else {
      setState(() {
        _todos.removeWhere((element) => element.isShopping);
      });
    }
  }

  void saveTotalPrice(double totalPrice) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalPrice', totalPrice);
  }

  void getTotalPrice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double doubleValue = prefs.getDouble('totalPrice') ?? 0.0;

    setState(() {
      totalPrice = doubleValue;
    });
  }

  void clearTotalPrice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('totalPrice');
  }
}
