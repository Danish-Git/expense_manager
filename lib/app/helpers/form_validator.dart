import 'package:get/get.dart';

class FormValidator {
  static String? validateAmount(dynamic amount, {bool isNumberRequired = true,}) {
    if(amount.toString().isEmpty && isNumberRequired) {
      return 'amount_is_required'.tr;
    } else if((amount.toString() == '.')) {
      return 'invalid_amount'.tr;
    } else {
      return null;
    }
  }

  static String? requiredFieldValidator(String val, {String? errorMsg}) {
    if (val.trim().isEmpty) {
      return errorMsg ?? 'this_field_is_required'.tr;
    }
    return null;
  }

  static bool validateIsItemSelected({List? list}) {
    return list?.firstWhereOrNull((element) => element.isSelected) != null;
  }
}