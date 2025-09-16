import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/staff_order.dart';

class DatabaseHelper {
  static const String _databaseName = 'staff_orders.db';
  static const int _databaseVersion = 1;

  static const String tableStaffOrders = 'staff_orders';

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = p.join(databasesPath, _databaseName);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableStaffOrders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staff_name TEXT NOT NULL,
        item TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        order_date INTEGER NOT NULL
      )
    ''');
  }

  Future<List<StaffOrder>> getAllStaffOrders() async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query(
      tableStaffOrders,
      orderBy: 'order_date DESC, id DESC',
    );
    return maps.map(StaffOrder.fromMap).toList();
  }

  Future<int> insertStaffOrder(StaffOrder order) async {
    final db = await database;
    return db.insert(tableStaffOrders, order.toMap());
  }

  Future<int> updateStaffOrder(StaffOrder order) async {
    final db = await database;
    if (order.id == null) {
      throw ArgumentError('Cannot update StaffOrder without id');
    }
    return db.update(
      tableStaffOrders,
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> deleteStaffOrder(int id) async {
    final db = await database;
    return db.delete(
      tableStaffOrders,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

