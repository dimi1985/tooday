import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tooday/screens/todo_list_screen.dart';
import 'package:tooday/utils/shopping_enabled_provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer timer;
  bool delayAnimation = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shoppingdProvider = Provider.of<ShoppingEnabledProvider>(context);

    timer = Timer(
        Duration(seconds: shoppingdProvider.geIsShoppingtEnabled ? 5 : 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TodoListScreen()),
      );
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final shoppingdProvider = Provider.of<ShoppingEnabledProvider>(context);
    return Scaffold(
      backgroundColor: shoppingdProvider.geIsShoppingtEnabled
          ? Color.fromARGB(255, 38, 121, 41)
          : Color.fromARGB(255, 102, 102, 102),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (shoppingdProvider.geIsShoppingtEnabled)
              Icon(
                Icons.shopping_bag,
                size: 50,
                color: Colors.white,
              ),
            if (!shoppingdProvider.geIsShoppingtEnabled)
              SizedBox(
                height: 75,
                width: 75,
                child: Image.asset('assets/images/logo.png'),
              ),
            SizedBox(height: 32.0),
            Text(
              'Tooday',
              style: TextStyle(
                fontSize: 36.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (shoppingdProvider.geIsShoppingtEnabled)
              Padding(
                padding: const EdgeInsets.only(left: 75),
                child: Text(
                  'Market',
                  style: TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
