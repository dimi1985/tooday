import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooday/database/database_helper.dart';
import 'package:tooday/utils/app_localization.dart';
import 'package:tooday/utils/theme_provider.dart';
import 'package:tooday/utils/user_signin_provider.dart';

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
    final userSgnInProvider = Provider.of<UserSignInProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
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

                      userSgnInProvider.isSignedIn = true;

                      // Store user's authentication state in shared preferences
                      _prefs.setBool(
                          'isSignedIn', userSgnInProvider.isSignedIn);

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
                  child: _isSigningIn
                      ? CircularProgressIndicator()
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image(
                                image:
                                    AssetImage('assets/images/google_logo.png'),
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
                                          color:
                                              themeProvider.isDarkThemeEnabled
                                                  ? Colors.white
                                                  : Colors.black54,
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
                                                        .translate(
                                                            'Signed in as:'),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: themeProvider
                                                              .isDarkThemeEnabled
                                                          ? Colors.white
                                                          : Colors.black54,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  Text(
                                                    _user!.displayName ?? '',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color: themeProvider
                                                              .isDarkThemeEnabled
                                                          ? Colors.white
                                                          : Colors.black54,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    _user!.email ?? '',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: themeProvider
                                                              .isDarkThemeEnabled
                                                          ? Colors.white
                                                          : Colors.black54,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              IconButton(
                                                  onPressed: () async {
                                                    await _googleSignIn
                                                        .signOut();
                                                    await _auth.signOut();
                                                    setState(() {
                                                      _user = null;
                                                      userSgnInProvider
                                                          .isSignedIn = false;
                                                      _prefs.setBool(
                                                          'isSignedIn',
                                                          userSgnInProvider
                                                              .isSignedIn);
                                                      _isSigningIn = false;
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
                                                .translate(
                                                    'Sign in with Google'),
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: themeProvider
                                                      .isDarkThemeEnabled
                                                  ? Colors.white
                                                  : Colors.black54,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                              )
                            ],
                          ),
                        ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
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
                                color: themeProvider.isDarkThemeEnabled
                                    ? Colors.white
                                    : Colors.black54,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              _user!.displayName ?? '',
                              style: TextStyle(
                                fontSize: 20,
                                color: themeProvider.isDarkThemeEnabled
                                    ? Colors.white
                                    : Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _user!.email ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: themeProvider.isDarkThemeEnabled
                                    ? Colors.white
                                    : Colors.black54,
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
                                userSgnInProvider.isSignedIn = false;
                                _prefs.setBool(
                                    'isSignedIn', userSgnInProvider.isSignedIn);
                              });
                              _isSigningIn = false;
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
      ),
    );
  }
}
