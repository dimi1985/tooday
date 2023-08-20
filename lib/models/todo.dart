class Todo {
  final int? id;
  final String title;
  bool isDone;
  final String description;
  bool isShopping;
  int quantity;
  double productPrice;
  double totalProductPrice;
  bool isHourSelected;
  String dueDate;
  int selectedTimeHour;
  int selectedTimeMinute;
  final int priority;
  String lastUpdated;
  bool isSync;
  String userId;
  bool isForTodo;
  bool isForShopping;

  Todo({
    this.id,
    required this.title,
    required this.isDone,
    required this.description,
    required this.isShopping,
    required this.quantity,
    required this.productPrice,
    required this.totalProductPrice,
    required this.isHourSelected,
    required this.selectedTimeHour,
    required this.selectedTimeMinute,
    required this.dueDate,
    required this.priority,
    required this.lastUpdated,
    required this.isSync,
    required this.userId,
    required this.isForTodo,
    required this.isForShopping,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone ? 1 : 0,
      'description': description,
      'isShopping': isShopping ? 1 : 0,
      'quantity': quantity,
      'productPrice': productPrice,
      'totalProductPrice': totalProductPrice,
      'isHourSelected': isHourSelected ? 1 : 0,
      'selectedTimeHour': selectedTimeHour,
      'selectedTimeMinute': selectedTimeMinute,
      'dueDate': dueDate,
      'priority': priority,
      'lastUpdated': lastUpdated,
      'isSync': isSync ? 1 : 0,
      'userId': userId,
      'isForTodo': isForTodo ? 1 : 0,
      'isForShopping': isForShopping ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'] == 1,
      description: map['description'],
      isShopping: map['isShopping'] == 1,
      quantity: map['quantity'],
      productPrice: map['productPrice'],
      totalProductPrice: map['totalProductPrice'],
      isHourSelected: map['isHourSelected'] == 1,
      selectedTimeHour: map['selectedTimeHour'],
      selectedTimeMinute: map['selectedTimeMinute'],
      dueDate: map['dueDate'],
      priority: map['priority'],
      lastUpdated: map['lastUpdated'],
      isSync: map['isSync'] == 1,
      userId: map['userId'],
      isForTodo: map['isForTodo'] == 1,
      isForShopping: map['isForShopping'] == 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'description': description,
      'isShopping': isShopping,
      'quantity': quantity,
      'productPrice': productPrice,
      'totalProductPrice': totalProductPrice,
      'isHourSelected': isHourSelected,
      'selectedTimeHour': selectedTimeHour,
      'selectedTimeMinute': selectedTimeMinute,
      'dueDate': dueDate,
      'priority': priority,
      'lastUpdated': lastUpdated,
      'isSync': isSync,
      'userId': userId,
      'isForTodo': isForTodo,
      'isForShopping': isForShopping,
    };
  }

  factory Todo.fromFireStore(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'],
      description: map['description'],
      isShopping: map['isShopping'],
      quantity: map['quantity'],
      productPrice: map['productPrice'],
      totalProductPrice: map['totalProductPrice'],
      isHourSelected: map['isHourSelected'],
      selectedTimeHour: map['selectedTimeHour'] ?? 0,
      selectedTimeMinute: map['selectedTimeMinute'] ?? 0,
      dueDate: map['dueDate'],
      priority: map['priority'],
      lastUpdated: map['lastUpdated'],
      isSync: map['isSync'],
      userId: map['userId'],
      isForTodo: map['isForTodo'],
      isForShopping: map['isForShopping'],
    );
  }

  // Named constructor for creating a new Todo instance with a new ID
  Todo.withNewId(Todo oldTodo, int newId)
      : id = newId,
        title = oldTodo.title,
        isDone = oldTodo.isDone,
        description = oldTodo.description,
        isShopping = oldTodo.isShopping,
        quantity = oldTodo.quantity,
        productPrice = oldTodo.productPrice,
        totalProductPrice = oldTodo.totalProductPrice,
        isHourSelected = oldTodo.isHourSelected,
        selectedTimeHour = oldTodo.selectedTimeHour,
        selectedTimeMinute = oldTodo.selectedTimeMinute,
        dueDate = oldTodo.dueDate,
        priority = oldTodo.priority,
        lastUpdated = oldTodo.lastUpdated,
        isSync = oldTodo.isSync,
        userId = oldTodo.userId,
        isForTodo = oldTodo.isForTodo,
        isForShopping = oldTodo.isForShopping;
}
