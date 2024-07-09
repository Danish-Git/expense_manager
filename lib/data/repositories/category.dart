import 'package:sqflite/sqflite.dart';
import '../../app/constants/sql_config.dart';
import '../../app/helpers/sql_helper.dart';
import '../../domain/db_provider.dart';
import '../models/data_models/category.dart';

class CategoryRepository {
  /// [bulkInsert] is used to bulk insert records in local DB
  Future<List<Object?>> bulkInsert(List<Map<String, dynamic>> categoriesJson) async {
    final dbClient = await DBProvider().db;
    Batch batch = dbClient!.batch();

    if(await SqlHelper().checkRecordExists(table: SqlConfig.categoryTableName, dbClient: dbClient)) return [];

    for (var category in categoriesJson) {
      batch.insert(SqlConfig.categoryTableName, category);
    }

    return await batch.commit(continueOnError:true);
  }

  ///   [loadCategories] this method is actually called from other classes to
  ///   add records of categories for the expense in local DB
  static Future<bool> loadCategories() async {
    List<Map<String, dynamic>>? json = CategoryModel().mockData;
    if(json.isNotEmpty) {
      var response = await CategoryRepository().bulkInsert(json);
      if(response.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  ///   [getCategories] method is used to get all records of categories from local DB
  static Future<List<CategoryModel>> getCategories() async {
    List<CategoryModel> categories = [];
    List<Map<String, dynamic>> list = await SqlHelper().getAllRecords(tableName: SqlConfig.categoryTableName);

    for (var element in list) {
      categories.add(CategoryModel.fromJson(element));
    }

    return categories;
  }
}