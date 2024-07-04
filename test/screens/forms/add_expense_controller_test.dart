import 'package:expense_manager/common/models/data_models/category.dart';
import 'package:expense_manager/common/models/data_models/expense.dart';
import 'package:expense_manager/screens/forms/add_expense/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {

  ExpenseFormController controller = ExpenseFormController();

  test('ExpenseFormController@setDateInput, Should updates text of date text field with formatted date', () {
    TextEditingController dateInput = TextEditingController();
    controller.dateInput = dateInput;
    DateTime selectedDate = DateTime(2023, 07, 04);
    controller.selectedDate = selectedDate;

    controller.setDateInput();

    expect(dateInput.text, "04-Jul-2023");
  });

  group("setEditFormData Method Tests", () {
    test('Sets isEditForm to true', () {
      controller = ExpenseFormController(expense: ExpenseModel(transactionDate: '2024-07-04'));
      controller.setEditFormData();
      expect(controller.isEditForm, isTrue);
    });

    test('Sets selectedDate correctly', () {
      controller = ExpenseFormController(expense: ExpenseModel(transactionDate: '2024-07-04'));
      controller.setEditFormData();
      expect(controller.selectedDate, DateTime.parse('2024-07-04'));
    });

    test('Sets amountInput text correctly', () {
      controller = ExpenseFormController(expense: ExpenseModel(transactionDate: '2024-07-04', amount: '100'));
      controller.setEditFormData();
      expect(controller.amountInput.text, '100');
    });

    test('Sets dateInput text correctly', () {
      controller = ExpenseFormController(expense: ExpenseModel(transactionDate: '2024-07-04'));
      controller.setEditFormData();
      expect(controller.dateInput.text, '04-Jul-2024');
    });

    test('Sets descriptionInput text correctly', () {
      controller = ExpenseFormController(expense: ExpenseModel(description: 'Test description', transactionDate: '2024-07-04'));
      controller.setEditFormData();
      expect(controller.descriptionInput.text, 'Test description');
    });

    test('Selects correct category', () {
      controller = ExpenseFormController(expense: ExpenseModel(categoryId: '1', transactionDate: '2024-07-04'));

      controller.categories = [
        CategoryModel(id: 1, name: 'Category A'),
        CategoryModel(id: 2, name: 'Category B'),
      ];

      controller.setEditFormData();
      expect(controller.selectedCategory?.id, 1);
      expect(controller.selectedCategory?.isSelected, true);
    });

    test('Does not select category if ID not found', () {
      controller = ExpenseFormController(expense: ExpenseModel(categoryId: '3', transactionDate: '2024-07-04'));

      controller.categories = [
        CategoryModel(id: 1, name: 'Category A'),
        CategoryModel(id: 2, name: 'Category B'),
      ];

      controller.setEditFormData();
      expect(controller.selectedCategory, isNull);
    });
  });

  group("Calculates isEditingAllowed correctly", () {
    test("When expense date is today's date", () {
      controller = ExpenseFormController(expense: ExpenseModel(transactionDate: DateTime.now().toString()));
      controller.setEditFormData();
      expect(controller.isEditingAllowed, true);
    });

    test("When the expense date is exactly two days ago from today", () {
      controller = ExpenseFormController(expense: ExpenseModel(transactionDate: DateTime.now().subtract(const Duration(days: 2)).toString()));
      controller.setEditFormData();
      expect(controller.isEditingAllowed, true);
    });

    test("When the expense date is exactly seven days ago from today", () {
      controller = ExpenseFormController(expense: ExpenseModel(transactionDate: DateTime.now().subtract(const Duration(days: 7)).toString()));
      controller.setEditFormData();
      expect(controller.isEditingAllowed, true);
    });

    test("When the expense date is exactly ten days ago from today", () {
      controller = ExpenseFormController(expense: ExpenseModel(transactionDate: DateTime.now().subtract(const Duration(days: 10)).toString()));
      controller.setEditFormData();
      expect(controller.isEditingAllowed, false);
    });
  });


  test("ExpenseFormController@setEditFormData, Should set up edit expense form correctly", () {

      controller.isEditForm = false;

      TextEditingController amountInput = TextEditingController();
      TextEditingController dateInput = TextEditingController();
      TextEditingController descriptionInput = TextEditingController();
      controller.amountInput = amountInput;
      controller.dateInput = dateInput;
      controller.descriptionInput = descriptionInput;

      DateTime transactionDate = DateTime(2023, 07, 04);
      controller = ExpenseFormController(expense: ExpenseModel(
        transactionDate: transactionDate.toString(),
        amount: '100',
        description: 'Sample expense',
        categoryId: '1',
      ));

      List<CategoryModel> categories = [
        CategoryModel(id: 1, name: 'Category 1'),
        CategoryModel(id: 2, name: 'Category 2'),
      ];
      controller.categories = categories;

      controller.setEditFormData();

      expect(controller.isEditForm, true);
      expect(controller.selectedDate, transactionDate);
      expect(controller.amountInput.text, '100');
      expect(controller.dateInput.text, '04-Jul-2023');
      expect(controller.descriptionInput.text, 'Sample expense');

      CategoryModel? selectedCategory = categories.firstWhereOrNull((category) => category.id == 1);
      expect(selectedCategory?.isSelected, true);
    });

  test('ExpenseFormController@selectCategory, Should updates selected category and categories list correctly', () {
    controller.isCategorySelected = false;

    List<CategoryModel> categories = [
      CategoryModel(id: 1, name: 'Category 1'),
      CategoryModel(id: 2, name: 'Category 2'),
    ];
    controller.categories = categories;

    int selectedIndex = 1;

    controller.selectCategory(selectedIndex, isUnitTest: true);

    expect(controller.selectedCategory, equals(categories[selectedIndex]));
    expect(controller.selectedCategory?.isSelected, true);

    expect(controller.categories?.length, equals(categories.length));
    expect(controller.categories?[selectedIndex].isSelected, true);

    expect(controller.isCategorySelected, true);
  });

}