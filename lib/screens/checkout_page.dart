import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tooday/database/database_helper.dart';
import 'package:tooday/screens/todo_list_screen.dart';
import 'package:tooday/utils/app_localization.dart';
import 'package:tooday/utils/shopping_enabled_provider.dart';
import 'package:tooday/widgets/custom_page_route.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutPage extends StatefulWidget {
  final double totalPrice;
  final bool itemsChecked;
  final ShoppingEnabledProvider shoppingdProvider;
  CheckoutPage(
      {required this.totalPrice,
      required this.itemsChecked,
      required this.shoppingdProvider});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  Widget build(BuildContext context) {
    String currentDate =
        DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());

    DatabaseHelper dbHelper = DatabaseHelper();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Checkout Page'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      AppLocalizations.of(context).translate('Date'),
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      '$currentDate',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      AppLocalizations.of(context).translate('Total Price:'),
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      '${widget.totalPrice.toStringAsFixed(2)}', // Assuming totalPrice is in dollars
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                MaterialButton(
                  onPressed: () {
                    launchGooglePay();
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
                      Image.asset(
                        'assets/images/google_pay.png',
                        height: 30.0,
                      ),
                      SizedBox(width: 16.0),
                      Text(
                        AppLocalizations.of(context)
                            .translate('Open Google Pay'),
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: 400,
                  height: 50,
                  child: MaterialButton(
                    onPressed: () {
                      if (widget.shoppingdProvider.geIsShoppingtEnabled) {
                        dbHelper.deleteAllShoppingItems();
                      }

                      Navigator.of(context).pushAndRemoveUntil(
                        CustomPageRoute(
                          child: TodoListScreen(),
                          forwardAnimation: false,
                          duration: Duration(milliseconds: 500),
                        ),
                        (route) => false,
                      );
                    },
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10.0), // Adjust the radius as needed
                    ),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('Go back to Shopping List'),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  launchGooglePay() async {
    bool result = await LaunchApp.isAppInstalled(
      androidPackageName: "com.google.android.apps.walletnfcrel",
      iosUrlScheme: "googlepay://",
    );

    if (result) {
      // Google Pay is installed, launch the app
      LaunchApp.openApp(
        androidPackageName: "com.google.android.apps.walletnfcrel",
        iosUrlScheme: "googlepay://",
      );
    } else {
      // Google Pay is not installed, open Google Play store
      launchUrl(Uri.parse(
          'market://details?id=com.google.android.apps.walletnfcrel'));
    }
  }
}
