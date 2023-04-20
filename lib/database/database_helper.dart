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
  static const columnTotalPrice = 'totalPrice';

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
        $columnTotalPrice REAL NOT NULL
      )
    ''');
  }

  Future<int> insert(Todo todo) async {
    final db = await database;
    return await db.insert(
      table,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    final result = await db.query(table);

    return result.map((map) => Todo.fromMap(map)).toList();
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

  Future<double?> getTotalPrice() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT SUM(totalPrice) FROM $table WHERE isDone = 1');
    return result.first.values.first as double?;
  }
}
