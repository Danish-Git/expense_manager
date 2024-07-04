import 'package:expense_manager/common/repositories/expense.dart';
import 'package:get/get.dart';

import '../../common/models/data_models/category.dart';
import '../../common/models/data_models/expense.dart';
import '../../common/models/data_models/history.dart';
import '../../common/repositories/category.dart';
import '../../utils/helpers/helper.dart';
import '../../utils/widgets/bottom_sheet/index.dart';
import '../forms/add_expense/index.dart';

class HistoryController extends GetxController {

  final ExpenseModel? expense;

  List<ExpenseModel>? expenses;
  List<CategoryModel>? categories;
  List<HistoryModel>? historyList;

  DateTime tempDate = DateTime.now();

  num totalAmount = 0;

  HistoryController({this.expense}) {
    if(expense != null) {
      onInit.call();
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadData();
  }

  Future<void> loadData() async {
    try {

      if(expense != null) await Future.delayed(const Duration(seconds: 1));

      expenses = [];
      categories = [];

      expenses = await ExpenseRepository.getAllExpense();
      categories = await CategoryRepository.getCategories();

      expenses?.forEach((expense) {
        expense.category = categories?.firstWhereOrNull((category) => category.id == int.tryParse(expense.categoryId ?? ""));
      });

      historyList = HistoryModel().fromExpenseList(expenses ?? []);

      update();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editExpense(bool isMobile, ExpenseModel expenseModel) async {
    ExpenseModel? expense = await getBottomSheet(
      isMobile: isMobile,
      child: ExpenseFormView(expense: expenseModel),
    );

    if(expense != null) {
      await loadData();
    }

  }

  String getFormattedDate(String date) {
    int difference = Helper.calculateDifference(DateTime.parse(date));
    switch(difference) {
      case 0:
        return "Today";
      case -1:
        return "Yesterday";
      default:
        return Helper.formatDate(DateTime.parse(date));
    }
  }
}