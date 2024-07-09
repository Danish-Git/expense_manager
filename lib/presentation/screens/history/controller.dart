import 'package:get/get.dart';
import '../../../app/helpers/helper.dart';
import '../../../data/models/data_models/category.dart';
import '../../../data/models/data_models/expense.dart';
import '../../../data/models/data_models/history.dart';
import '../../../data/repositories/category.dart';
import '../../../data/repositories/expense.dart';
import '../../global/widgets/bottom_sheet/index.dart';
import '../forms/add_expense/index.dart';

class HistoryController extends GetxController {

  /// [expenses],[categories] are the lists to store data which is read for local BD
  List<ExpenseModel>? expenses;
  List<CategoryModel>? categories;

  /// [historyList] is a final list to represent complete history of expenses
  List<HistoryModel>? historyList;

  /// [isLoading] is used to manage loading state while fetching data from local DB
  bool isLoading = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadData();
  }

  ///   [loadData] this method is used to load initial data
  Future<void> loadData() async {
    try {
      toggleIsLoading();
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
    } finally {
      toggleIsLoading();
    }
  }

  ///   [addEditExpense] is a method is used open expense add / edit form
  ///   in addition it expects for some result from expense form on obtaining
  ///   result it reloads the screen
  Future<void> addEditExpense({required bool isMobile, ExpenseModel? expenseModel}) async {
    ExpenseModel? expense = await getBottomSheet(
      isMobile: isMobile,
      child: ExpenseFormView(expense: expenseModel),
    );

    if(expense != null) {
      await loadData();
    }
  }

  ///   [getFormattedDate] this method is used to format date for the purpose of displaying
  String getFormattedDate(String date) {
    int difference = Helper.calculateDifference(DateTime.parse(date));
    switch(difference) {
      case 0:
        return "today".tr;
      case -1:
        return "yesterday".tr;
      default:
        return Helper.formatDate(DateTime.parse(date));
    }
  }
  ///   [toggleIsLoading] this method is used to alter the state of loading
  void toggleIsLoading() {
    isLoading = !isLoading;
    update();
  }
}