// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooday/database/database_helper.dart';
import 'package:tooday/models/todo.dart';
import 'package:tooday/utils/app_localization.dart';
import 'package:tooday/widgets/custom_check_box.dart';

import '../widgets/theme_provider.dart';

class AddEditTodoScreen extends StatefulWidget {
  final Todo todo;
  final Future<void> Function() fetchFunction;

  const AddEditTodoScreen({
    Key? key,
    required this.todo,
    required this.fetchFunction,
  }) : super(key: key);

  @override
  _AddEditTodoScreenState createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isStayOnScreen = false;
  late bool _isDone;
  bool hasDescription = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.todo.title;
    descriptionController.text = widget.todo.description;
    _isDone = widget.todo.isDone;

    getStayOnScreenBool();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
          widget.todo.id == null
              ? AppLocalizations.of(context).translate(
                  'Add Todo',
                )
              : AppLocalizations.of(context).translate('Edit Todo'),
          style: TextStyle(
            color: themeProvider.isDarkThemeEnabled
                ? Colors.white
                : const Color.fromARGB(255, 37, 37, 37),
          ),
        ),

        actions: [
          widget.todo.id == null
              ? Container()
              : IconButton(
                  onPressed: () {
                    _showPopUpDeleteDialog(widget.todo);
                  },
                  icon: Icon(IconlyLight.delete))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)
                        .translate('text_edit_title'),
                    labelStyle: TextStyle(color: Colors.blueGrey),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 146, 171, 192)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey),
                    ),
                  ),
                  cursorColor: Colors.blueGrey, // Set cursor color
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)
                          .translate('Please enter a title');
                    }
                    return null;
                  },
                  onSaved: (value) {
                    titleController.text = value!;
                  },
                ),
                const SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: widget.todo.id == null
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                                AppLocalizations.of(context).translate('Done')),
                            const Spacer(),
                            CustomCheckbox(
                              isChecked: _isDone,
                              onChanged: (value) {
                                setState(() {
                                  _isDone = value!;
                                  _doTheMagic('CheckBox_Only');
                                });
                              },
                            ),
                          ],
                        ),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)
                        .translate('text_edit_description'),
                    labelStyle: TextStyle(color: Colors.blueGrey),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 146, 171, 192)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey),
                    ),
                  ),
                  cursorColor: Colors.blueGrey, // Set cursor color

                  onSaved: (value) {
                    descriptionController.text = value!;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Theme(
        data: ThemeData(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                secondary: Colors.blueGrey[800], // Change the color of the FAB
              ),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: FloatingActionButton(
          onPressed: () {
            _doTheMagic('');
          },
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Change the shape of the FAB
          ),
          child: const Icon(Icons.save),
        ),
      ),
    );
  }

  void _doTheMagic(String action) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final todo = Todo(
        id: widget.todo.id,
        title: titleController.text.trim(),
        isDone: _isDone,
        description: descriptionController.text.trim(),
      );

      final dbHelper = DatabaseHelper();

      if (widget.todo.id == null) {
        dbHelper.insert(todo);
      } else {
        dbHelper.update(todo);
      }

      if (action == 'CheckBox_Only') {
        widget.fetchFunction();
      } else {
        conditionalSave();
      }
    }
  }

  void _showPopUpDeleteDialog(Todo todo) {
    // Show confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('Delete Todo?')),
          content: Text(AppLocalizations.of(context)
              .translate('Are you sure you want to delete this todo?')),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context).translate('Cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context).translate('Delete')),
              onPressed: () {
                // Delete the todo and navigate back to the TodoListScreen
                final dbHelper = DatabaseHelper();
                dbHelper.delete(todo.id ?? 0);
                widget.fetchFunction();
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void conditionalSave() async {
    if (isStayOnScreen) {
      widget.fetchFunction();
      titleController.clear();
      return;
    } else {
      widget.fetchFunction();
      Navigator.pop(context);
    }
  }

  void getStayOnScreenBool() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool stayOnAddTodoScreen = prefs.getBool('stayOnAddTodoScreen') ?? false;
    setState(() {
      isStayOnScreen = stayOnAddTodoScreen;
    });
  }
}
