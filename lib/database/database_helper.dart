import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tooday/models/todo.dart';

class DatabaseHelper {
  static const _databaseName = 'todo_database.db';
  static const _databaseVersion = 1;

  static const table = 'todos';

  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnIsDone = 'isDone';
  static const columnDescription = 'description';
  static const columnIsShopping = 'isShopping';
  static const columnQuantity = 'quantity';
  static const columnProductPrice = 'productPrice';
  static const columnpTotalProductPrice = 'totalProductPrice';
  static const columnhourSelected = 'selectedTimeHour';
  static const columnminuteSelected = 'selectedTimeMinute';
  static const columnIsHourSelected = 'isHourSelected';
  static const columnDueDate = 'dueDate';
  static const columnPriority = 'priority';
  static const columnLastUpdated = 'lastUpdated';
  static const columnIsSync = 'isSync';
  static const columnUserId = 'userId';
  static const columnIsForTodo = 'isForTodo';
  static const columnIsForShopping = 'isForShopping';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, _databaseName);

    return await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnIsDone INTEGER NOT NULL,
        $columnDescription TEXT NOT NULL,
        $columnIsShopping INTEGER NOT NULL,
        $columnQuantity INTEGER NOT NULL,
        $columnProductPrice REAL NOT NULL,
        $columnpTotalProductPrice REAL NOT NULL,
        $columnIsHourSelected INTEGER NOT NULL,
        $columnhourSelected INTEGER NOT NULL,
        $columnminuteSelected INTEGER NOT NULL,
        $columnDueDate TEXT NOT NULL,
        $columnPriority INTEGER NOT NULL,
        $columnLastUpdated TEXT NOT NULL,
        $columnIsSync INTEGER NOT NULL,
        $columnUserId TEXT NOT NULL,
        $columnIsForTodo INTEGER NOT NULL,
        $columnIsForShopping INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insert(Todo todo) async {
    final db = await database;
    return await db.insert(
      table,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<bool> checkIfTodoItemExists(Todo todo) async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT * FROM $table WHERE title LIKE '%${todo.title}%' AND description LIKE '%${todo.description}%' AND isShopping = 0");
    return result.isNotEmpty;
  }

  Future<bool> checkIfShoppingItemExists(Todo todo) async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT * FROM $table WHERE title LIKE '%${todo.title}%' AND description LIKE '%${todo.description}%' AND isShopping = 1");
    return result.isNotEmpty;
  }

  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    final result = await db.query(table);

    return result.map((map) => Todo.fromMap(map)).toList();
  }

  Future<Todo?> getTodoById(int? id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Todo.fromMap(maps.first);
    } else {
      return null; // Return null if todo with the given ID is not found
    }
  }

  Future<int> update(Todo todo) async {
    final db = await database;
    return await db.update(
      table,
      todo.toMap(),
      where: '$columnId = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteDoneTodos() async {
    final db = await database;
    await db.delete('todos', where: 'isDone = ?', whereArgs: [1]);
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete(table);
  }

  Future<void> deleteAllShoppingItems() async {
    final db = await database;
    await db.delete(
      table,
      where: 'isShopping = ?',
      whereArgs: [1],
    );
  }

  Future<void> deleteAllTodoExceptShoppingItems() async {
    final db = await database;
    await db.delete(
      table,
      where: 'isShopping = ?',
      whereArgs: [0],
    );
  }

  Future<List<Todo>> getSyncedTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('todos', where: 'isSync = ?', whereArgs: [1]);
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<int> getLastInsertedId() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      columns: ['id'],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first['id'] as int;
    } else {
      return 0;
    }
  }

  Future<List<Todo>> getIsHourSelectedItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('todos', where: 'isHourSelected = ?', whereArgs: [1]);
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<List<Todo>> getAllUncheckTodos() async {
    final db = await database;
    final result = await db.query(
      table,
      where: "isDone = ? AND isShopping = ?",
      whereArgs: [0, 0],
    );
    return result.map((map) => Todo.fromMap(map)).toList();
  }

  Future<List<Todo>> getUncheckTodos() async {
    final db = await database;
    final result = await db.query(
      table,
      where: "isForTodo = ? AND isForShopping = ? AND isDone = ?",
      whereArgs: [1, 0, 0],
    );
    return result.map((map) => Todo.fromMap(map)).toList();
  }

  Future<List<Todo>> getUnBoughtShoppingItems() async {
    final db = await database;
    final result = await db.query(
      table,
      where: "isForTodo = ? AND isForShopping = ? AND isDone = ?",
      whereArgs: [0, 1, 0],
    );
    return result.map((map) => Todo.fromMap(map)).toList();
  }
}
