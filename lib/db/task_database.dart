import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Task model class
class Task {
  final int? id;
  final String title;
  final String category;
  final String priority;
  final DateTime dueDate;
  final bool isDone;

  Task({
    this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.dueDate,
    this.isDone = false,
  });

  /// Copy method to create a new Task with modified fields
  Task copyWith({
    int? id,
    String? title,
    String? category,
    String? priority,
    DateTime? dueDate,
    bool? isDone,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
    );
  }

  /// Convert Task to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'priority': priority,
      'dueDate': dueDate.toIso8601String(),
      'isDone': isDone ? 1 : 0,
    };
  }

  /// Create Task from Map from SQLite
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      priority: map['priority'],
      dueDate: DateTime.parse(map['dueDate']),
      isDone: map['isDone'] == 1,
    );
  }
}

/// Database helper class
class TaskDatabase {
  static final TaskDatabase instance = TaskDatabase._init();
  static Database? _database;

  TaskDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        priority TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        isDone INTEGER NOT NULL
      )
    ''');
  }

  Future<Task> create(Task task) async {
    final db = await instance.database;
    final id = await db.insert('tasks', task.toMap());
    return task.copyWith(id: id);
  }

  Future<List<Task>> readAllTasks() async {
    final db = await instance.database;
    final orderBy = 'dueDate ASC';
    final result = await db.query('tasks', orderBy: orderBy);
    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<int> update(Task task) async {
    final db = await instance.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
