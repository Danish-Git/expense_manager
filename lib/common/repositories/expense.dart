import 'package:expense_manager/utils/constants/sql_config.dart';
import 'package:expense_manager/utils/helpers/sql_helper.dart';

import '../models/data_models/expense.dart';
import '../providers/db_provider.dart';

class ExpenseRepository {

  ///   [getAllRecords] method is used to get all records of expenses available
  ///   in local DB. It returns result in the form og JSON object
  Future<List<Map<String, dynamic>>> getAllRecords() async {
    final dbClient = await DBProvider().db;
    return (await dbClient!.rawQuery("SELECT * FROM ${SqlConfig.expensesTableName} ORDER BY transaction_date DESC,  id DESC")).toList();
  }

  ///   [insertExpense] method is used to add a record of expense in local DB
  static Future<ExpenseModel>? insertExpense({Map<String, dynamic>? params}) async {
    int? id = await SqlHelper().insert(tableName: SqlConfig.expensesTableName, params: params!);
    if(id != null && id != 0) {
      params.addEntries({"id" : id}.entries);
    }
    return ExpenseModel.fromJson(params);
  }

  ///   [getAllExpense] this method is actually called from other classes to
  ///   fetch all records of expenses and pars them from JSON object to data model
  static Future<List<ExpenseModel>>? getAllExpense() async {
    List<ExpenseModel> expenses = [];
    List<Map<String, dynamic>>? list = await ExpenseRepository().getAllRecords();
    for (var element in list) {
      expenses.add(ExpenseModel.fromJson(element));
    }
    return expenses;
  }

  ///   [updateExpense] method is use to update the already recorded expense
  static Future<ExpenseModel>? updateExpense({required Map<String, dynamic> params, int? id}) async {
    await SqlHelper().update(tableName: SqlConfig.expensesTableName, params: params, id: id);
    if(id != null && id != 0) {
      params.addEntries({"id" : id}.entries);
    }
    return ExpenseModel.fromJson(params);
  }

  ///   [deleteExpense] method is used to delete an existing record of an expense from local DB
  static Future<bool> deleteExpense({int? id}) async {
    var response = await SqlHelper().delete(tableName: SqlConfig.expensesTableName, id: id);
    return (response[0] == "1" || response[0] == 1 || response[0] == "true" || response[0] == true);
  }
}