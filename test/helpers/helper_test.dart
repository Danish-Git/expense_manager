import 'package:expense_manager/app/helpers/helper.dart';
import 'package:expense_manager/data/models/data_models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Helper@hideKeyboard should hide keyboard", () {
    testWidgets('Does not throw when keyboard is already hidden', (WidgetTester tester) async {
      expect(() => Helper.hideKeyboard, returnsNormally);
    });

    testWidgets('Does not throw when keyboard is focused', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: TextField(key: Key('testTextField')),
        ),
      ));

      await tester.tap(find.byKey(const Key('testTextField')));
      await tester.pump();

      expect(FocusManager.instance.primaryFocus, isNotNull);
      expect(() => Helper.hideKeyboard, returnsNormally);
    });
  });

  group("Helper@selectItemFromList, Should ensure only item is selected when a selection is made", () {
    test('Returns empty list when list is empty', () {
      List<CategoryModel> list = [];
      List<CategoryModel> result = Helper.selectItemFromList(list: list, selectedIndex: 0).cast<CategoryModel>();
      expect(result, isEmpty);
    });

    test('Selects the correct item when a valid index is provided', () {
      List<CategoryModel> list = [CategoryModel(), CategoryModel(), CategoryModel()];
      List<CategoryModel> result = Helper.selectItemFromList(list: list, selectedIndex: 1).cast<CategoryModel>();
      expect(result[0].isSelected, isFalse);
      expect(result[1].isSelected, isTrue);
      expect(result[2].isSelected, isFalse);
    });

    test('Deselects other items when a new selection is made', () {
      List<CategoryModel> list = [CategoryModel(), CategoryModel(), CategoryModel()];
      list[1].isSelected = true;
      List<CategoryModel> result = Helper.selectItemFromList(list: list, selectedIndex: 0).cast<CategoryModel>();
      expect(result[0].isSelected, isTrue);
      expect(result[1].isSelected, isFalse);
      expect(result[2].isSelected, isFalse);
    });

    test('Does not select any item when an invalid index is provided', () {
      List<CategoryModel> list = [CategoryModel(), CategoryModel(), CategoryModel()];
      List<CategoryModel> result = Helper.selectItemFromList(list: list, selectedIndex: -1).cast<CategoryModel>();
      expect(result[0].isSelected, isFalse);
      expect(result[1].isSelected, isFalse);
      expect(result[2].isSelected, isFalse);
    });

    test('Selects the last item when the last index is provided', () {
      List<CategoryModel> list = [CategoryModel(), CategoryModel(), CategoryModel()];
      List<CategoryModel> result = Helper.selectItemFromList(list: list, selectedIndex: 2).cast<CategoryModel>();
      expect(result[0].isSelected, isFalse);
      expect(result[1].isSelected, isFalse);
      expect(result[2].isSelected, isTrue);
    });
  });

  group("Helper@formatDate, Should provide date in correct format", () {
    test('Formats date correctly for a standard date', () {
      DateTime date = DateTime(2024, 7, 4);
      String formattedDate = Helper.formatDate(date);
      expect(formattedDate, '04-Jul-2024');
    });

    test('Formats date correctly for a leap year date', () {
      DateTime date = DateTime(2024, 2, 29);
      String formattedDate = Helper.formatDate(date);
      expect(formattedDate, '29-Feb-2024');
    });

    test('Formats date correctly for end of year', () {
      DateTime date = DateTime(2024, 12, 31);
      String formattedDate = Helper.formatDate(date);
      expect(formattedDate, '31-Dec-2024');
    });

    test('Formats date correctly for beginning of year', () {
      DateTime date = DateTime(2024, 1, 1);
      String formattedDate = Helper.formatDate(date);
      expect(formattedDate, '01-Jan-2024');
    });

    test('Formats date correctly for single-digit day and month', () {
      DateTime date = DateTime(2024, 3, 9);
      String formattedDate = Helper.formatDate(date);
      expect(formattedDate, '09-Mar-2024');
    });
  });

  group("Helper@calculateDifference, Should calculate the difference in days between a given date and today", () {
    test('Returns 0 for today\'s date', () {
      DateTime today = DateTime.now();
      int difference = Helper.calculateDifference(today);
      expect(difference, 0);
    });

    test('Returns -1 for yesterday\'s date', () {
      DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
      int difference = Helper.calculateDifference(yesterday);
      expect(difference, -1);
    });

    test('Returns positive value for a past date', () {
      DateTime pastDate = DateTime.now().subtract(const Duration(days: 5));
      int difference = Helper.calculateDifference(pastDate);
      expect(difference, lessThan(0)); // Should be negative since it's in the past
    });

    test('Returns positive value for a future date', () {
      DateTime futureDate = DateTime.now().add(const Duration(days: 5));
      int difference = Helper.calculateDifference(futureDate);
      expect(difference, greaterThan(0)); // Should be positive since it's in the future
    });
  });
}