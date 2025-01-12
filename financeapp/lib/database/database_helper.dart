import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper.init();
  static Database? database;

  DatabaseHelper.init();

  Future<Database> get db async {
    if (database != null) return database!;
    database = await initDB('transactions.db');
    return database!;
  }

  Future<Database> initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: createDB,
    );
  }

  Future createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';

    await db.execute('''
    CREATE TABLE transactions (
      id $idType,
      description $textType,
      amount $doubleType,
      type $textType,
      date $textType
    )
  ''');
  }

  Future<List<Map<String, dynamic>>> fetchTransactions({
    DateTime? startDate,
    DateTime? endDate,
    bool isAscending = false,
  }) async {
    final db = await instance.db;

    final orderBy = 'date ${isAscending ? 'ASC' : 'DESC'}';
    String? where;
    List<Object?>? whereArgs;

    if (startDate != null && endDate != null) {
      where = 'date BETWEEN ? AND ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }

    return await db.query(
      'transactions',
      orderBy: orderBy,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<void> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await instance.db;
    await db.insert('transactions', transaction);
  }
}
