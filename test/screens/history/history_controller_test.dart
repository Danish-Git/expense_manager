import 'package:expense_manager/app/helpers/helper.dart';
import 'package:expense_manager/presentation/screens/history/controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  HistoryController controller = HistoryController();

  group("HistoryController@getFormattedDate Should provide correct format of date", () {

    test('Should provide "Today" for today\'s date', () {
      final today = DateTime.now().toIso8601String();
      expect(controller.getFormattedDate(today), equals("today".tr));
    });

    test('Should provide "Yesterday" for yesterday\'s date', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
      expect(controller.getFormattedDate(yesterday), equals("yesterday".tr));
    });

    test('Should provide formatted date for other dates', () {
      final otherDate = DateTime.now().subtract(const Duration(days: 2)).toIso8601String();
      final formattedDate = Helper.formatDate(DateTime.parse(otherDate));
      expect(controller.getFormattedDate(otherDate), equals(formattedDate));
    });
  });
}