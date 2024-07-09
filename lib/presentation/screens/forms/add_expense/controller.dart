import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/constants/app_config.dart';
import '../../../../app/helpers/form_validator.dart';
import '../../../../app/helpers/helper.dart';
import '../../../../data/models/data_models/category.dart';
import '../../../../data/models/data_models/expense.dart';
import '../../../../data/repositories/category.dart';
import '../../../../data/repositories/expense.dart';

class ExpenseFormController extends GetxController {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ExpenseModel? expense;

  /// [amountInput], [dateInput], [descriptionInput] are controllers of text
  /// input fields used to control inputs of different types and there values
  TextEditingController amountInput = TextEditingController();
  TextEditingController dateInput = TextEditingController();
  TextEditingController descriptionInput = TextEditingController();

  ///   [selectedDate] is used to hold the value of date which is selected as an input for there expense
  DateTime selectedDate = DateTime.parse(DateFormat("yyy-MM-dd").format(DateTime.now()));

  ///   [categories] is used to hold the list of categories fetched from local DB
  List<CategoryModel>? categories;

  ///   [selectedCategory] is used to hold the value of selected category
  CategoryModel? selectedCategory;

  ///   [isCategorySelected] is used for validation purpose
  bool isCategorySelected = true;

  ///   [isEditForm] is used to switch form in edit mode`
  bool isEditForm = false;

  ///   [isEditingAllowed] is used to handel view only and edit mode
  bool isEditingAllowed = true;

  ExpenseFormController({this.expense});

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  ///   [loadData] method is used to load initial data which is required for recording expense
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

  ///   [selectDate] method is used to open date selector to select expense date
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

  ///   [setDateInput] method is used to set the selected date in text input field
  void setDateInput() {
    dateInput.text = Helper.formatDate(selectedDate);
  }

  ///   [setEditFormData] method is used in case of edit and view mode to fill
  ///   the form with previously recorded expense data
  void setEditFormData() {
    isEditForm = true;
    selectedDate = DateTime.parse(expense?.transactionDate ?? "");
    isEditingAllowed = (Helper.calculateDifference(selectedDate)).abs() <= AppConfig.maxExpenseManagementDuration.inDays;
    amountInput.text = expense?.amount ?? "";
    dateInput.text = Helper.formatDate(selectedDate);
    descriptionInput.text = expense?.description ?? "";
    selectedCategory = categories?.firstWhereOrNull((category) => category.id == int.tryParse(expense?.categoryId ?? ""))?..isSelected = true;
  }

  ///   [selectCategory] method is used to update selected category
  void selectCategory(int index, {bool? isUnitTest}) {
    if(!(isUnitTest ?? false)) Helper.hideKeyboard;
    selectedCategory = categories![index]..isSelected = true;
    categories = Helper.selectItemFromList(list: categories!.cast<dynamic>(), selectedIndex: index).cast<CategoryModel>();
    isCategorySelected = true;
    update();
  }

  ///   [validateForm] method is used to validate form and proceed further to save record
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

  ///   [saveExpense] method is used to save expense data in local DB. This
  ///   method is used in both adding and editing case
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

  ///   [deleteExpense] method is used to delete expense data from local DB
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