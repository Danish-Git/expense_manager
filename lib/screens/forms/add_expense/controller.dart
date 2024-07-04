import 'package:expense_manager/utils/constants/app_config.dart';
import 'package:expense_manager/utils/helpers/form_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../common/models/data_models/category.dart';
import '../../../common/models/data_models/expense.dart';
import '../../../common/repositories/category.dart';
import '../../../common/repositories/expense.dart';
import '../../../utils/helpers/helper.dart';

class ExpenseFormController extends GetxController {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ExpenseModel? expense;

  TextEditingController amountInput = TextEditingController();
  TextEditingController dateInput = TextEditingController();
  TextEditingController descriptionInput = TextEditingController();

  DateTime selectedDate = DateTime.parse(DateFormat("yyy-MM-dd").format(DateTime.now()));

  List<CategoryModel>? categories;

  bool isCategorySelected = true;
  bool isEditForm = false;
  bool isEditingAllowed = true;
  CategoryModel? selectedCategory;

  ExpenseFormController({this.expense});

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      categories = [];
      categories = await CategoryRepository.getCategories();

      setDateInput();
      if(expense != null) setEditFormData();
      update();
    } catch (e) {
      rethrow;
    }
  }

  void selectDate(BuildContext context) async {
    Helper.hideKeyboard;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(AppConfig.maxExpenseManagementDuration),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      selectedDate = pickedDate;
      setDateInput();
    }
    update();
  }

  void setDateInput() {
    dateInput.text = Helper.formatDate(selectedDate);
  }

  void setEditFormData() {
    isEditForm = true;
    selectedDate = DateTime.parse(expense?.transactionDate ?? "");
    isEditingAllowed = (Helper.calculateDifference(selectedDate)).abs() <= AppConfig.maxExpenseManagementDuration.inDays;
    amountInput.text = expense?.amount ?? "";
    dateInput.text = Helper.formatDate(selectedDate);
    descriptionInput.text = expense?.description ?? "";
    selectedCategory = categories?.firstWhereOrNull((category) => category.id == int.tryParse(expense?.categoryId ?? ""))?..isSelected = true;
  }

  void selectCategory(int index, {bool? isUnitTest}) {
    if(!(isUnitTest ?? false)) Helper.hideKeyboard;
    selectedCategory = categories![index]..isSelected = true;
    categories = Helper.selectItemFromList(list: categories!.cast<dynamic>(), selectedIndex: index).cast<CategoryModel>();
    isCategorySelected = true;
    update();
  }

  void validateForm() {
    Helper.hideKeyboard;
    if(Helper.validateForm(formKey)) {
      if(!FormValidator.validateIsItemSelected(list: categories)) {
        isCategorySelected = false;
        update();
      } else {
        saveExpense();
      }
    }
  }

  Future<void> saveExpense() async {
    try {
      Map<String, dynamic> params = {
        "amount": amountInput.text,
        "transaction_date": selectedDate.toString(),
        "description": descriptionInput.text,
        "category_id": selectedCategory?.id,
        "created_at": DateTime.now().toString(),
      };
      ExpenseModel? expenseModel;

      if(isEditForm) {
        expenseModel = await ExpenseRepository.updateExpense(params: params, id: expense?.id);
      } else {
        expenseModel = await ExpenseRepository.insertExpense(params: params);
      }
      Get.back(result: expenseModel);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteExpense() async {
    bool isDeleted = await ExpenseRepository.deleteExpense(id: expense?.id);
    if(isDeleted) Get.back(result: expense);
  }

  @override
  void dispose() {
    amountInput.dispose();
    dateInput.dispose();
    descriptionInput.dispose();
    super.dispose();
  }
}