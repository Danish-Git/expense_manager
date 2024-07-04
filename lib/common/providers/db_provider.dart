import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../utils/constants/sql_config.dart';


class DBProvider {
  static Database? _db;

  Future<Database?> get db async {
    _db ??= await initDatabase();
    return _db;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, SqlConfig.dataBaseName);
    var db = await openDatabase(path, version: SqlConfig.dbVersion, onCreate: onCreate, onUpgrade: onUpgrade, onDowngrade: onDowngrade);
    return db;
  }

  onCreate(Database db, int version) {
    Batch batch = db.batch();

    /// Tables creation
    /// 1. user
    /// 2. category
    /// 3. expenses

    batch.execute('''CREATE TABLE ${SqlConfig.userTableName}(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      first_name TEXT,
      last_name TEXT,
      email TEXT,
      profile_pic TEXT
      )''');

    batch.execute('''CREATE TABLE ${SqlConfig.categoryTableName}(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      icon TEXT
      )''');

    batch.execute('''CREATE TABLE ${SqlConfig.expensesTableName}(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      amount TEXT,
      description TEXT,
      transaction_date TEXT,
      category_id INTEGER,
      user_id INTEGER,
      created_at TEXT,
      updated_at TEXT
      )''');

    return batch.commit(continueOnError: true);
  }

  /// [onUpgrade] will be called on updating version number
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.batch().commit(continueOnError: true);
  }

  /// [onDowngrade] will be called on downgrading version number
  Future<void> onDowngrade(Database db, int oldVersion, int newVersion) async {
    await db.batch().commit(continueOnError: true);
  }

}