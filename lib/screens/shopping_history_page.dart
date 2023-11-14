import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tooday/utils/app_localization.dart';
import 'package:tooday/utils/theme_provider.dart';

class ShoppingHistoryPage extends StatefulWidget {
  final ThemeProvider themeProvider;
  ShoppingHistoryPage(this.themeProvider);

  @override
  _ShoppingHistoryPageState createState() => _ShoppingHistoryPageState();
}

class _ShoppingHistoryPageState extends State<ShoppingHistoryPage> {
  List<Map<String, dynamic>> shoppingData = [];
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    getFireStoreTodos();
  }

  void getFireStoreTodos() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('todo_history').get();

    setState(() {
      shoppingData = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  void _showContextMenu(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).translate('Confirm Deletion'),
          ),
          content: SizedBox(
            height: 150,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).translate(
                      'Are you sure you want to delete shopping date:'),
                ),
                Text(
                  '${DateFormat('dd-MM HH:mm:ss').format(item['date'].toDate())} ?',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                AppLocalizations.of(context).translate('Cancel'),
              ),
            ),
            TextButton(
              onPressed: () async {
                await deleteDocumentsByTotalPrice(item['totalPrice']);
                setState(() {
                  getFireStoreTodos();
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                AppLocalizations.of(context).translate('Delete'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<double, List<Map<String, dynamic>>> groupedData = {};

    shoppingData.forEach((item) {
      double totalPrice = item['totalPrice'];

      if (groupedData.containsKey(totalPrice)) {
        groupedData[totalPrice]!.add(item);
      } else {
        groupedData[totalPrice] = [item];
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: widget.themeProvider.isDarkThemeEnabled
              ? Colors.white
              : Colors.black,
        ),
        title: Text(
          AppLocalizations.of(context).translate('Shopping History'),
          style: TextStyle(
            color: widget.themeProvider.isDarkThemeEnabled
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
      body: groupedData.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.of(context)
                    .translate('There is no Purchase History Yet'),
              ),
            )
          : ListView.builder(
              itemCount: groupedData.length,
              itemBuilder: (context, index) {
                double totalPrice = groupedData.keys.elementAt(index);
                List<Map<String, dynamic>> items = groupedData[totalPrice]!;

                return GestureDetector(
                  onLongPress: () => _showContextMenu(context, items.first),
                  child: Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ExpansionTile(
                      onExpansionChanged: (value) {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      title: !isExpanded
                          ? Row(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(AppLocalizations.of(context)
                                        .translate('Date')),
                                    Container(
                                      width: 75,
                                      child: Text(
                                        ': ${DateFormat('dd-MM').format(items.first['date'].toDate())}',
                                        style: TextStyle(
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .translate('Price'),
                                        style: TextStyle(
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                    Text(': ${totalPrice.toStringAsFixed(2)}'),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(AppLocalizations.of(context)
                                        .translate('Date')),
                                    Spacer(),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(AppLocalizations.of(context)
                                            .translate('Total Price:')),
                                        Text(
                                            '${totalPrice.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  width: 200,
                                  child: Text(
                                    '${DateFormat('dd-MM HH:mm').format(items.first['date'].toDate())}',
                                    style: TextStyle(
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ],
                            ),
                      children: items.map((item) {
                        return ListTile(
                          title: Text(item['title']),
                          subtitle: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(AppLocalizations.of(context)
                                        .translate('Quantity')),
                                  ),
                                  Text(item['quantity'].toString())
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(AppLocalizations.of(context)
                                        .translate('Product Price')),
                                  ),
                                  Text(item['productPrice'].toString())
                                ],
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
    );
  }

  deleteDocumentsByTotalPrice(double totalPrice) async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('todo_history');

    QuerySnapshot querySnapshot = await collectionReference
        .where('totalPrice', isEqualTo: totalPrice)
        .get();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      await documentSnapshot.reference.delete();
    }
  }
}
