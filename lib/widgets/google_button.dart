import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooday/database/database_helper.dart';
import 'package:tooday/utils/app_localization.dart';

import '../models/todo.dart';
import '../utils/shopping_enabled_provider.dart';

class GoogleSignInButton extends StatefulWidget {
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;
  User? _user;
  late SharedPreferences _prefs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _prefs = prefs;
        _isSigningIn = _prefs.getBool('isSignedIn') ?? false;
        _user = _isSigningIn ? _auth.currentUser : null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _user == null
              ? MaterialButton(
                  onPressed: () async {
                    setState(() {
                      _isSigningIn = true;
                    });

                    try {
                      // Trigger the authentication flow
                      GoogleSignInAccount? googleUser =
                          await _googleSignIn.signIn();

                      // Obtain the auth details from the request
                      final GoogleSignInAuthentication googleAuth =
                          await googleUser!.authentication;

                      // Create a new credential
                      final credential = GoogleAuthProvider.credential(
                        accessToken: googleAuth.accessToken,
                        idToken: googleAuth.idToken,
                      );

                      // Sign in with Google account using the credential
                      final UserCredential userCredential =
                          await _auth.signInWithCredential(credential);

                      // Store user's authentication state in shared preferences
                      await _prefs.setBool('isSignedIn', true);

                      //update usrID
                      await _prefs.setString('userId', _auth.currentUser!.uid);

                      setState(() {
                        _isSigningIn = false;

                        _user = userCredential.user;
                      });
                    } catch (error) {
                      print(error);
                      setState(() {
                        _isSigningIn = false;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage('assets/images/google_logo.png'),
                          height: 35.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: _user == null
                              ? Text(
                                  AppLocalizations.of(context)
                                      .translate('Sign in with Google'),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : _user != null
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)
                                                  .translate('Signed in as:'),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              _user!.displayName ?? '',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              _user!.email ?? '',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                            onPressed: () async {
                                              await _googleSignIn.signOut();
                                              await _auth.signOut();
                                              setState(() {
                                                _user = null;
                                                _prefs.remove('isSignedIn');
                                              });
                                            },
                                            icon: Icon(
                                              Icons.exit_to_app,
                                              color: Colors.red,
                                            ))
                                      ],
                                    )
                                  : Text(
                                      AppLocalizations.of(context)
                                          .translate('Sign in with Google'),
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                        )
                      ],
                    ),
                  ),
                )
              : MaterialButton(
                  onPressed: syncFireStore,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)
                                .translate('Signed in as:'),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            _user!.displayName ?? '',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _user!.email ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                          onPressed: () async {
                            await _googleSignIn.signOut();
                            await _auth.signOut();
                            setState(() {
                              _user = null;
                              _prefs.remove('isSignedIn');
                            });
                          },
                          icon: Icon(
                            Icons.exit_to_app,
                            color: Colors.red,
                          ))
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  syncFireStore() async {
    final dbHelper = DatabaseHelper();
    // Download synced todos from Firestore
    final syncedTodoDocs = await FirebaseFirestore.instance
        .collection('todos')
        .where('isSync', isEqualTo: true)
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .get();

    final syncedTodoData =
        syncedTodoDocs.docs.map((doc) => doc.data()).toList();

// Save synced todos to local database
    for (final data in syncedTodoData) {
      final fireStoreTodo = Todo.fromMap(data);

      bool shoppingItemExists = false;
      dbHelper.checkIfShoppingItemExists(fireStoreTodo).then((value) {
        setState(() {
          shoppingItemExists = value;
        });
      });
      bool todoItemListExists = false;
      dbHelper.checkIfTodoItemExists(fireStoreTodo).then((value) {
        setState(() {
          todoItemListExists = value;
        });
      });
      final shoppingdProvider =
          Provider.of<ShoppingEnabledProvider>(context, listen: false);

      final newtodo = Todo(
        id: fireStoreTodo.id,
        title: fireStoreTodo.title,
        isDone: fireStoreTodo.isDone,
        description: fireStoreTodo.description,
        isShopping: shoppingdProvider.geIsShoppingtEnabled ? true : false,
        quantity: fireStoreTodo.quantity,
        productPrice: fireStoreTodo.productPrice,
        totalProductPrice: fireStoreTodo.totalProductPrice,
        entryDate: fireStoreTodo.entryDate,
        dueDate: fireStoreTodo.dueDate,
        priority: fireStoreTodo.priority,
        lastUpdated: fireStoreTodo.lastUpdated,
        isSync: true,
      );

      if (!shoppingItemExists || !todoItemListExists) {
        await dbHelper.insert(newtodo);
      }
    }
  }
}
