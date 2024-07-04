import 'package:expense_manager/common/models/data_models/category.dart';
import 'package:expense_manager/utils/constants/sql_config.dart';
import 'package:sqflite/sqflite.dart';

import '../../utils/helpers/sql_helper.dart';
import '../providers/db_provider.dart';

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

  static Future<List<CategoryModel>> getCategories() async {
    List<CategoryModel> categories = [];
    List<Map<String, dynamic>> list = await SqlHelper().getAllRecords(tableName: SqlConfig.categoryTableName);

    for (var element in list) {
      categories.add(CategoryModel.fromJson(element));
    }

    return categories;
  }
}