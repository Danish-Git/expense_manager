import 'package:expense_manager/utils/themes/index.dart';
import 'package:expense_manager/utils/widgets/text/constants/font_size.dart';
import 'package:expense_manager/utils/widgets/text/constants/font_weight.dart';
import 'package:expense_manager/utils/widgets/text/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Helper {

  static get hideKeyboard => FocusManager.instance.primaryFocus?.unfocus();

  static List selectItemFromList({required List list, required int selectedIndex}) {
    for(int index = 0; index < list.length ; index++) {
      if(index == selectedIndex) {
        list[index].isSelected = true;
      } else {
        list[index].isSelected = false;
      }
    }
    return list;
  }

  static bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState!.validate();
  }

  static String formatDate(DateTime selectedDate) {
    return DateFormat('dd-MMM-yyyy').format(selectedDate).toString();
  }

  static int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  static Widget showLoading() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SpinKitFadingCircle(
        color: EMAppTheme.themeColors.darkGray,
        size: 80,
      ),
    ],
  );

  static showErrorMessage({String? message, IconData? icon}) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(icon ?? Icons.search_off_outlined, size: 60),
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: TextWidget(
          text: message ?? "no_data_found".tr,
          fontSize: EMFontSize.subTitle,
          fontWeight: EMFontWeight.medium,
        ),
      ),
    ],
  );
}