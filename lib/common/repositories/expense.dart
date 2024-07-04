import 'package:expense_manager/utils/constants/sql_config.dart';
import 'package:expense_manager/utils/helpers/sql_helper.dart';

import '../models/data_models/expense.dart';
import '../providers/db_provider.dart';

class ExpenseRepository {

  ///   Getting status if data exists in table
  Future<List<Map<String, dynamic>>> getAllRecords() async {
    final dbClient = await DBProvider().db;
    return (await dbClient!.rawQuery("SELECT * FROM ${SqlConfig.expensesTableName} ORDER BY transaction_date DESC,  id DESC")).toList();
  }

  static Future<ExpenseModel>? insertExpense({Map<String, dynamic>? params}) async {
    int? id = await SqlHelper().insert(tableName: SqlConfig.expensesTableName, params: params!);
    if(id != null && id != 0) {
      params.addEntries({"id" : id}.entries);
    }
    return ExpenseModel.fromJson(params);
  }

  static Future<List<ExpenseModel>>? getAllExpense() async {
    List<ExpenseModel> expenses = [];
    List<Map<String, dynamic>>? list = await ExpenseRepository().getAllRecords();
    for (var element in list) {
      expenses.add(ExpenseModel.fromJson(element));
    }
    return expenses;
  }

  static Future<ExpenseModel>? updateExpense({required Map<String, dynamic> params, int? id}) async {
    await SqlHelper().update(tableName: SqlConfig.expensesTableName, params: params, id: id);
    if(id != null && id != 0) {
      params.addEntries({"id" : id}.entries);
    }
    return ExpenseModel.fromJson(params);
  }

  static Future<bool> deleteExpense({int? id}) async {
    var response = await SqlHelper().delete(tableName: SqlConfig.expensesTableName, id: id);
    return (response[0] == "1" || response[0] == 1 || response[0] == "true" || response[0] == true);
  }
}