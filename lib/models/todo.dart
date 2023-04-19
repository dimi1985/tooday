class Todo {
  final int? id;
  final String title;
  bool isDone;
  final String description;

  Todo({
    this.id,
    required this.title,
    required this.isDone,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone ? 1 : 0,
      'description': description,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'] == 1,
      description: map['description'],
    );
  }
}
