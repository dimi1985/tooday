SizedBox(
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
      DateTime now = DateTime.now();
      setState(() {
        modalQuantity = int.tryParse(value) ??
            widget.todo.quantity;
        productPrice =
            widget.todo.productPrice;
        totalProductPrice =
            calculateTotalProductPrice();
        final newTodo = Todo(
          id: widget.todo.id,
          title: widget.todo.title,
          isDone: true,
          description:
              widget.todo.description,
          isShopping: widget.todo.isShopping,
          quantity: modalQuantity,
          productPrice: productPrice,
          totalProductPrice:
              totalProductPrice,
          isHourSelected:
              widget.todo.isHourSelected,
          dueDate: widget.todo.dueDate,
          priority: widget.todo.priority,
          lastUpdated: now.toIso8601String(),
          isSync: widget.todo.isSync,
          userId: widget.todo.userId,
          selectedTimeHour: 0,
          selectedTimeMinute: 0,
          isForTodo: widget.todo.isForTodo,
          isForShopping:
              widget.todo.isForShopping,
        );

        dbHelper.update(newTodo);
      });
    },
  ),
)