// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooday/models/todo.dart';
import 'package:tooday/screens/add_edit_todo_screen.dart';
import 'package:tooday/screens/settings_screen.dart';
import 'package:tooday/utils/app_localization.dart';
import 'package:tooday/widgets/custom_check_box.dart';
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
  @override
  void initState() {
    super.initState();
    _fetchTodos();
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
      isLoading = false;
    });
    loadOrder();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkThemeEnabled
          ? Color.fromARGB(255, 39, 39, 39)
          : Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: themeProvider.isDarkThemeEnabled ? Colors.white : Colors.black,
        ),
        backgroundColor: themeProvider.isDarkThemeEnabled
            ? const Color.fromARGB(255, 39, 39, 39)
            : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: PopupMenuButton(
              icon: const Icon(IconlyLight.more_square),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 'Settings',
                    child: Text(
                        AppLocalizations.of(context).translate('Settings')),
                  ),
                  PopupMenuItem(
                    value: 'Clear Data',
                    child: Text(
                        AppLocalizations.of(context).translate('Clear Data')),
                  ),
                  PopupMenuItem(
                    value: 'Clear Selected',
                    child: Text(AppLocalizations.of(context)
                            .translate('Clear Selected') +
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
                    _fetchTodos();
                    break;
                  case 'Clear Selected':
                    // Handle Clear Selected action
                    _todos.removeWhere((todo) => todo.isDone);

                    dbHelper.deleteDoneTodos();
                    _fetchTodos();
                    break;
                }
              },
            ),
            onPressed: () {},
          ),
        ],
        title: Text(
          AppLocalizations.of(context).translate('title'),
          style: TextStyle(
              color: themeProvider.isDarkThemeEnabled
                  ? Colors.white
                  : Colors.black),
        ),
      ),
      body: isLoading
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
              ? Container(
                  color: themeProvider.isDarkThemeEnabled
                      ? Color.fromARGB(255, 39, 39, 39)
                      : Colors.white, // Change background color here
                  child: Center(
                      child: Text(AppLocalizations.of(context)
                          .translate('List is appears Empty'))),
                )
              // _refreshIndicatorKey
              : ReorderableListView(
                  onReorder: (int oldIndex, int newIndex) {
                    reOrderTodoList(newIndex, oldIndex);
                  },
                  children: List.generate(
                    _todos.length,
                    (index) {
                      final todo = _todos[index];

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
                                  color:
                                      todo.isDone ? Colors.green : Colors.grey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ListTile(
                                title: Text(todo.title,
                                    style: todo.isDone
                                        ? const TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.grey)
                                        : null),
                                trailing: CustomCheckbox(
                                  isChecked: todo.isDone,
                                  onChanged: (value) {
                                    setState(() {
                                      todo.isDone = value!;

                                      dbHelper.update(todo);
                                      checkedTodosCounT =
                                          getCheckedTodosCount(_todos);
                                    });
                                  },
                                ),
                                onTap: () => _navigateToEditScreen(
                                    context, todo, _todos, index),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
          onPressed: () {
            _navigateToAddScreen(context);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(IconlyLight.plus),
        ),
      ),
    );
  }

  void _navigateToAddScreen(BuildContext context) {
    final newTodo = Todo(isDone: false, title: '');
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
}
