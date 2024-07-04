import 'package:sqflite/sqflite.dart';

import '../../common/providers/db_provider.dart';

class SqlHelper {
  /// [checkTableExists] is used to check if a given table exists in local db
  Future<bool> checkTableExists({Database? dbClient, required String table}) async {
    final newDbClient = dbClient ?? await DBProvider().db;
    List<Map<String, dynamic>>? resources = (await newDbClient!.rawQuery("SELECT name FROM sqlite_master WHERE type = 'table' AND name = '$table'")).toList();
    return resources.isNotEmpty;
  }

  /// [getLastAddedId] is used to get last added record of given table from local db
  Future<int?> getLastAddedId({Database? dbClient, required String table}) async {
    final newDbClient = dbClient ?? await DBProvider().db;
    List<Map<String, dynamic>>? resources = (await newDbClient!.rawQuery("SELECT COUNT(*) AS count FROM $table")).toList();
    if(resources.isNotEmpty) {
      return resources[0]["count"];
    } else {
      return null;
    }
  }

  /// [checkRecordExists] is used to check if some data exists in a given table
  Future<bool> checkRecordExists({Database? dbClient, required String table}) async {
    bool tableExists = await checkTableExists(table: table, dbClient: dbClient);

    if(tableExists) {
      int? response = await getLastAddedId(table: table, dbClient: dbClient);
      if(response != null && response != 0) return true;
    }
    return false;
  }

  /// [getAllRecords] is used to get all records from given table of local DB
  Future<List<Map<String, dynamic>>> getAllRecords({required String tableName, Database? dbClient}) async {
    final newDbClient = dbClient ?? await DBProvider().db;
    return (await newDbClient!.rawQuery("SELECT * FROM $tableName")).toList();
  }

  /// [insert] is used to insert a records in given table of local DB
  Future<int?> insert({required String tableName, required Map<String, dynamic> params}) async {
    final dbClient = await DBProvider().db;
    Batch batch = dbClient!.batch();
    batch.insert(tableName, params);
    await batch.commit(continueOnError: true);
    return getLastAddedId(table: tableName, dbClient: dbClient);
  }

  /// [update] is used to update a records from given table of local DB
  Future<List<Object?>> update({required String tableName, required Map<String, dynamic> params, int? id}) async {
    final dbClient = await DBProvider().db;
    Batch batch = dbClient!.batch();
    batch.update(tableName, params, where: "id = ?", whereArgs: [id]);
    return await batch.commit(continueOnError: true);
  }

  /// [delete] is used to delete a records from given table of local DB
  Future<List<Object?>> delete({required String tableName, int? id}) async {
    final dbClient = await DBProvider().db;
    Batch batch = dbClient!.batch();
    batch.delete(tableName, where: "id == $id");
    return await batch.commit(continueOnError: true);
  }

}