// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooday/database/database_helper.dart';
import 'package:tooday/models/todo.dart';
import 'package:tooday/utils/app_localization.dart';
import 'package:tooday/widgets/custom_check_box.dart';
import 'package:tooday/widgets/shopping_enabled_provider.dart';

import '../widgets/theme_provider.dart';

class AddEditTodoScreen extends StatefulWidget {
  final Todo todo;
  final Future<void> Function() fetchFunction;
  bool isForEdit;

  AddEditTodoScreen({
    Key? key,
    required this.todo,
    required this.fetchFunction,
    required this.isForEdit,
  }) : super(key: key);

  @override
  _AddEditTodoScreenState createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isStayOnScreen = false;
  late bool _isDone;
  late bool shoppingExists = false;
  late bool todoItemExists = false;
  final _focusNodeTitle = FocusNode();
  final _focusNodeDescription = FocusNode();

  bool hasDescription = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  double totalPrice = 0.0;
  int modalQuantity = 1;
  double productPrice = 0.0;
  double totalProductPrice = 0.0;
  final dbHelper = DatabaseHelper();
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
    descriptionController.clear();
    _focusNodeTitle.dispose();
    _focusNodeDescription.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final shoppingdProvider = Provider.of<ShoppingEnabledProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        // Fetch updated todos here
        await widget.fetchFunction();
        return true;
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
            widget.todo.id == null
                ? AppLocalizations.of(context).translate(
                    shoppingdProvider.geIsShoppingtEnabled
                        ? 'Add Shopping Item'
                        : 'Add Todo',
                  )
                : AppLocalizations.of(context).translate(
                    shoppingdProvider.geIsShoppingtEnabled
                        ? 'Edit Shopping Item'
                        : 'Edit Todo'),
            style: TextStyle(
              color: themeProvider.isDarkThemeEnabled
                  ? Colors.white
                  : const Color.fromARGB(255, 37, 37, 37),
            ),
          ),

          actions: [
            widget.todo.id == null
                ? Container()
                : Row(
                    children: [
                      widget.isForEdit
                          ? Container()
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  widget.isForEdit = true;
                                });
                              },
                              icon: Icon(IconlyLight.swap),
                            ),
                      IconButton(
                        onPressed: () {
                          _showPopUpDeleteDialog(widget.todo);
                        },
                        icon: Icon(IconlyLight.delete),
                      ),
                    ],
                  ),
          ],
        ),
        body: SingleChildScrollView(
          child: widget.isForEdit
              ? Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Padding(
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
                                setState(() {
                                  widget.isForEdit = false;
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
                          widget.todo.title.isEmpty
                              ? AppLocalizations.of(context).translate(
                                  'No Title',
                                )
                              : widget.todo.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.todo.description.isEmpty
                              ? AppLocalizations.of(context).translate(
                                  'No Description',
                                )
                              : widget.todo.description,
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
                                      controller: quantityController,
                                      textInputAction: TextInputAction.done,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText:
                                            widget.todo.quantity.toString(),
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          modalQuantity = value.isEmpty
                                              ? int.parse(widget.todo.quantity
                                                  .toString())
                                              : int.parse(value);
                                          totalProductPrice =
                                              widget.todo.quantity *
                                                  productPrice;

                                          final newTodo = Todo(
                                            id: widget.todo.id,
                                            title: widget.todo.title,
                                            isDone: widget.todo.isDone,
                                            description:
                                                widget.todo.description,
                                            isShopping: widget.todo.isShopping,
                                            quantity: modalQuantity,
                                            productPrice: productPrice,
                                            totalProductPrice:
                                                totalProductPrice,
                                            totalPrice: widget.todo.totalPrice,
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
                                        labelText:
                                            widget.todo.productPrice.toString(),
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          productPrice = value.isEmpty
                                              ? widget.todo.productPrice
                                              : double.tryParse(value
                                                      .replaceAll(',', '.')) ??
                                                  widget.todo.productPrice;
                                          totalProductPrice =
                                              modalQuantity * productPrice;

                                          final newTodo = Todo(
                                            id: widget.todo.id,
                                            title: widget.todo.title,
                                            isDone: widget.todo.isDone,
                                            description:
                                                widget.todo.description,
                                            isShopping: widget.todo.isShopping,
                                            quantity: modalQuantity,
                                            productPrice: productPrice,
                                            totalProductPrice:
                                                totalProductPrice,
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
                            'Total Price: \E${totalProductPrice == 0 ? widget.todo.totalProductPrice.toStringAsFixed(2) : totalProductPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          focusNode: _focusNodeTitle,
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context).translate(
                                shoppingdProvider.geIsShoppingtEnabled
                                    ? 'text_edit_title_shopping'
                                    : 'text_edit_title'),
                            labelStyle: TextStyle(color: Colors.blueGrey),
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 146, 171, 192)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueGrey),
                            ),
                          ),
                          cursorColor: Colors.blueGrey, // Set cursor color
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context).translate(
                                  shoppingdProvider.geIsShoppingtEnabled
                                      ? 'Please enter a product'
                                      : 'Please enter a title');
                            } else {
                              if (shoppingExists) {
                                setState(() {
                                  titleController.text = '';
                                });
                                return AppLocalizations.of(context).translate(
                                    shoppingdProvider.geIsShoppingtEnabled
                                        ? 'Exist'
                                        : 'Exist');
                              }
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(AppLocalizations.of(context).translate(
                                        shoppingdProvider.geIsShoppingtEnabled
                                            ? '"Put in Cart'
                                            : 'Done')),
                                    const Spacer(),
                                    CustomCheckbox(
                                      isChecked: _isDone,
                                      onChanged: (value) {
                                        setState(() {
                                          _isDone = value!;
                                          _doTheMagic('CheckBox_Only',
                                              shoppingdProvider);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                        ),
                        TextFormField(
                          focusNode: _focusNodeDescription,
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)
                                .translate('text_edit_description'),
                            labelStyle: TextStyle(color: Colors.blueGrey),
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 146, 171, 192)),
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
        floatingActionButton: widget.isForEdit
            ? Container()
            : Theme(
                data: ThemeData(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        secondary:
                            Colors.blueGrey[800], // Change the color of the FAB
                      ),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    _doTheMagic('', shoppingdProvider);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Change the shape of the FAB
                  ),
                  child: const Icon(Icons.save),
                ),
              ),
      ),
    );
  }

  Future<void> _doTheMagic(
      String action, ShoppingEnabledProvider shoppingdProvider) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final todo = Todo(
        id: widget.todo.id,
        title: titleController.text.trim(),
        isDone: _isDone,
        description: descriptionController.text.trim(),
        isShopping: shoppingdProvider.geIsShoppingtEnabled ? true : false,
        quantity: widget.todo.quantity,
        productPrice: widget.todo.productPrice,
        totalProductPrice: widget.todo.totalProductPrice,
        totalPrice: widget.todo.totalPrice,
      );

      final dbHelper = DatabaseHelper();
// todoExists
      Future<bool> shoppingItemExists =
          dbHelper.checkIfShoppingItemExists(todo);
      Future<bool> todoItemListExists = dbHelper.checkIfTodoItemExists(todo);
      shoppingExists = await shoppingItemExists;
      todoItemExists = await todoItemListExists;
      if (widget.todo.id == null) {
        if (shoppingExists || todoItemExists) {
          setState(() {
            if (titleController.text.isNotEmpty && _focusNodeTitle.hasFocus) {
              _showExitsSnackBar(context);
              titleController.text = '';
            } else if (descriptionController.text.isNotEmpty &&
                _focusNodeDescription.hasFocus) {
              descriptionController.text = '';
              _showExitsSnackBar(context);
            }
          });
          return;
        } else {
          dbHelper.insert(todo);
        }
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
      descriptionController.clear();
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

  void _showExitsSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).translate('Already Exists')),
      ),
    );
  }
}
