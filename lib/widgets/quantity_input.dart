import 'package:flutter/material.dart';

class QuantityInput extends StatefulWidget {
  final int initialQuantity;
  final Function(int) onQuantityChanged;

  QuantityInput(
      {required this.initialQuantity, required this.onQuantityChanged});

  @override
  _QuantityInputState createState() => _QuantityInputState();
}

class _QuantityInputState extends State<QuantityInput> {
  late int modalQuantity;

  @override
  void initState() {
    super.initState();
    modalQuantity = widget.initialQuantity;
  }

  void _incrementQuantity() {
    setState(() {
      modalQuantity++;
      widget.onQuantityChanged(modalQuantity);
    });
  }

  void _decrementQuantity() {
    if (modalQuantity > 0) {
      setState(() {
        modalQuantity--;
        widget.onQuantityChanged(modalQuantity);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: _decrementQuantity,
        ),
        SizedBox(
          width: 70,
          child: Text(
            modalQuantity.toString(),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: _incrementQuantity,
        ),
      ],
    );
  }
}
