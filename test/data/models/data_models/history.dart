import 'package:expense_manager/data/models/data_models/expense.dart';
import 'package:expense_manager/data/models/data_models/history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  HistoryModel historyModel = HistoryModel();

  group('HistoryModel@fromExpenseList, Should provide correct formatted expense history data', () {
    test('returns empty list when given an empty list', () {
      List<ExpenseModel> emptyList = [];
      var result = historyModel.fromExpenseList(emptyList);
      expect(result.isEmpty, true);
    });

    test('converts a list of expenses with single date correctly', () {
      List<ExpenseModel> expenses = [
        ExpenseModel(transactionDate: '2023-01-01', amount: '10'),
        ExpenseModel(transactionDate: '2023-01-01', amount: '20'),
        ExpenseModel(transactionDate: '2023-01-01', amount: '30'),
      ];

      var result = historyModel.fromExpenseList(expenses);

      expect(result.length, 1);
      expect(result[0].date, '2023-01-01 00:00:00.000');
      expect(result[0].total, '60'); // Sum of amounts (10 + 20 + 30)
      expect(result[0].items?.length, 3); // Three items in the history for this date
    });

    test('correctly splits expenses into different dates', () {
      List<ExpenseModel> expenses = [
        ExpenseModel(transactionDate: '2023-01-01', amount: '10'),
        ExpenseModel(transactionDate: '2023-01-02', amount: '20'),
        ExpenseModel(transactionDate: '2023-01-02', amount: '30'),
        ExpenseModel(transactionDate: '2023-01-03', amount: '40'),
        ExpenseModel(transactionDate: '2023-01-03', amount: '50'),
      ];

      var result = historyModel.fromExpenseList(expenses);

      expect(result.length, 3); // Three different dates
      expect(result[0].date, '2023-01-01 00:00:00.000');
      expect(result[0].total, '10');
      expect(result[0].items?.length, 1);

      expect(result[1].date, '2023-01-02 00:00:00.000');
      expect(result[1].total, '50'); // Sum of amounts (20 + 30)
      expect(result[1].items?.length, 2);

      expect(result[2].date, '2023-01-03 00:00:00.000');
      expect(result[2].total, '90'); // Sum of amounts (40 + 50)
      expect(result[2].items?.length, 2);
    });

    test('handles empty amounts correctly', () {
      List<ExpenseModel> expenses = [
        ExpenseModel(transactionDate: '2023-01-01', amount: '10'),
        ExpenseModel(transactionDate: '2023-01-01', amount: ''),
        ExpenseModel(transactionDate: '2023-01-01', amount: '30'),
      ];

      var result = historyModel.fromExpenseList(expenses);

      expect(result.length, 1);
      expect(result[0].date, '2023-01-01 00:00:00.000');
      expect(result[0].total, '40'); // Sum of amounts (10 + 0 + 30)
      expect(result[0].items?.length, 3);
    });
  });
}