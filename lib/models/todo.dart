class Todo {
  final int? id;
  final String title;
  bool isDone;
  final String description;
  bool isShopping;
  int quantity;
  double productPrice;
  double totalProductPrice;
  String entryDate;
  String dueDate;
  final int priority;
  String lastUpdated;
  bool isSync;

  Todo({
    this.id,
    required this.title,
    required this.isDone,
    required this.description,
    required this.isShopping,
    required this.quantity,
    required this.productPrice,
    required this.totalProductPrice,
    required this.entryDate,
    required this.dueDate,
    required this.priority,
    required this.lastUpdated,
    required this.isSync,
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
      'entryDate': entryDate,
      'dueDate': dueDate,
      'priority': priority,
      'lastUpdated': lastUpdated,
      'isSync': isSync ? 1 : 0,
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
      entryDate: map['entryDate'],
      dueDate: map['dueDate'],
      priority: map['priority'],
      lastUpdated: map['lastUpdated'],
      isSync: map['isSync'] == 1,
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
      'entryDate': entryDate,
      'dueDate': dueDate,
      'priority': priority,
      'lastUpdated': lastUpdated,
      'isSync': isSync,
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
      entryDate: map['entryDate'],
      dueDate: map['dueDate'],
      priority: map['priority'],
      lastUpdated: map['lastUpdated'],
      isSync: map['isSync'],
    );
  }
}
