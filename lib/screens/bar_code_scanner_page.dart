import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String _scanResult = "";
  String _productName = "";
  String _productPrice = "";
  bool _isLoading = false;

  Future<String> _scanBarcode() async {
    String result = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", true, ScanMode.BARCODE);
    return result;
  }

  Future<void> _getProductInfo(String barcode) async {
    setState(() {
      _isLoading = true;
    });
    var url = Uri.parse(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);
      if (decodedData['status'] == 1) {
        setState(() {
          _productName = decodedData['product']['product_name'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _productName = 'Product not found';
          _isLoading = false;
        });
      }
    } else {
      print(response.statusCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Screen'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      String barcode = await _scanBarcode();
                      setState(() {
                        _scanResult = barcode;
                      });
                      await _getProductInfo(_scanResult);
                    },
                    child: Text('Scan Barcode'),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    _scanResult,
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Product Name: $_productName',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Product Price: $_productPrice',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ],
              ),
      ),
    );
  }
}
