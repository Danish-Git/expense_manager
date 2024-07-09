import 'package:expense_manager/app/helpers/form_validator.dart';
import 'package:expense_manager/data/models/data_models/category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  group("FormValidator@validateAmount should validate amount is written in correct format", () {
    test('Returns error when amount is empty and number is required', () {
      expect(FormValidator.validateAmount("", isNumberRequired: true), equals('amount_is_required'.tr));
    });

    test('Returns null when amount is empty and number is not required', () {
      expect(FormValidator.validateAmount("", isNumberRequired: false), isNull);
    });

    test('Returns error when amount is a dot', () {
      expect(FormValidator.validateAmount("."), equals('invalid_amount'.tr));
    });

    test('Returns null for valid amounts', () {
      expect(FormValidator.validateAmount("10"), isNull);
      expect(FormValidator.validateAmount(10), isNull);
      expect(FormValidator.validateAmount(10.5), isNull);
    });

    test('Returns null for valid amount strings', () {
      expect(FormValidator.validateAmount("10.5"), isNull);
      expect(FormValidator.validateAmount("0"), isNull);
      expect(FormValidator.validateAmount("100"), isNull);
    });
  });

  group("FormValidator@requiredFieldValidator, Should validate required data", () {
    test('Returns error when input is empty and no custom error message is provided', () {
      expect(FormValidator.requiredFieldValidator(""), equals('this_field_is_required'.tr));
    });

    test('Returns error when input is empty and custom error message is provided', () {
      expect(FormValidator.requiredFieldValidator("", errorMsg: "Custom error message"), equals("Custom error message"));
    });

    test('Returns null when input is not empty', () {
      expect(FormValidator.requiredFieldValidator("Valid input"), isNull);
    });

    test('Trims input before validation', () {
      expect(FormValidator.requiredFieldValidator("   "), equals('this_field_is_required'.tr));
      expect(FormValidator.requiredFieldValidator("  Valid input  "), isNull);
    });
  });

  group("FormValidator@validateIsItemSelected, Should validate if a item is selected from list", () {
    test('Returns false when list is null', () {
      expect(FormValidator.validateIsItemSelected(list: null), isFalse);
    });

    test('Returns false when list is empty', () {
      expect(FormValidator.validateIsItemSelected(list: []), isFalse);
    });

    test('Returns false when no item is selected', () {
      List<CategoryModel> categoryList = [CategoryModel(), CategoryModel()];
      expect(FormValidator.validateIsItemSelected(list: categoryList), isFalse);
    });

    test('Returns true when at least one item is selected', () {
      List<CategoryModel> categoryList = [CategoryModel(), CategoryModel()];
      categoryList[categoryList.length - 1].isSelected = true;
      expect(FormValidator.validateIsItemSelected(list: categoryList), isTrue);
    });

    test('Returns true when the first item is selected', () {
      List<CategoryModel> categoryList = [CategoryModel(), CategoryModel()];
      categoryList[0].isSelected = true;
      expect(FormValidator.validateIsItemSelected(list: categoryList), isTrue);
    });

    test('Returns true when all items are selected', () {
      List<CategoryModel> categoryList = [CategoryModel(), CategoryModel()];
      for (var element in categoryList) {
        element.isSelected = true;
      }
      expect(FormValidator.validateIsItemSelected(list: categoryList), isTrue);
    });
  });
}