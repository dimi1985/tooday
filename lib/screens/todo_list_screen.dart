// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tooday/main.dart';
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

  static Future<List<Todo>> getList() async{
    final dbHelper = DatabaseHelper();
    final todos = await dbHelper.getAllTodos();
    return todos;
    }

}

class _TodoListScreenState extends State<TodoListScreen> {
  late List<Todo> _todos = [];
  int checkedTodosCounT = 0;
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final dbHelper = DatabaseHelper();
    final todos = await dbHelper.getAllTodos();
    
    setState(() {
      _todos = todos;
      checkedTodosCounT = getCheckedTodosCount(_todos);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
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
        title: Text(AppLocalizations.of(context).translate('title')),

        backgroundColor: themeProvider.isDarkThemeEnabled
            ? const Color.fromARGB(255, 37, 37, 37)
            : Colors.blueGrey[800], // Change app bar color here
      ),
      body: _todos.isEmpty
          ? Container(
              color: themeProvider.isDarkThemeEnabled
                  ? const Color.fromARGB(255, 37, 37, 37)
                  : const Color.fromARGB(
                      255, 104, 104, 104), // Change background color here
              child: Center(
                  child: Text(
                      AppLocalizations.of(context).translate('Nothing Here'))),
            )
          : ReorderableListView(
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _todos.removeAt(oldIndex);
                  _todos.insert(newIndex, item);
                });
              },
              children: List.generate(
                _todos.length,
                (index) {
                  final todo = _todos[index];

                  return ListTile(
                    key: ValueKey(todo.id),
                    title: Text(todo.title,
                        style: todo.isDone
                            ? TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: themeProvider.isDarkThemeEnabled
                                    ? const Color.fromARGB(255, 160, 160, 160)
                                    : const Color.fromARGB(255, 182, 182, 182),
                              )
                            : null),
                    trailing: CustomCheckbox(
                      isChecked: todo.isDone,
                      onChanged: (value) {
                        setState(() {
                          todo.isDone = value!;

                          dbHelper.update(todo);
                          checkedTodosCounT = getCheckedTodosCount(_todos);
                        });
                      },
                    ),
                    tileColor: todo.isDone
                        ? themeProvider.isDarkThemeEnabled
                            ? const Color.fromARGB(255, 110, 110, 110)
                            : Colors.grey[300]
                        : null, // gray out done todos

                    onTap: () => _navigateToEditScreen(context, todo),
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
        builder: (context) =>
            AddEditTodoScreen(todo: newTodo, fetchFunction: _fetchTodos),
      ),
    ).then((value) {
      if (value == true) {
        _fetchTodos();
      }
    });
  }

  void _navigateToEditScreen(BuildContext context, Todo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddEditTodoScreen(todo: todo, fetchFunction: _fetchTodos),
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
        builder: (context) => const SettingsPage(),
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
}
