import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../presentation/global/widgets/text/constants/font_size.dart';
import '../../presentation/global/widgets/text/constants/font_weight.dart';
import '../../presentation/global/widgets/text/index.dart';
import '../themes/index.dart';

class Helper {

  ///   [hideKeyboard] is used to hide keyboard then user clicks on no editable item
  static get hideKeyboard => FocusManager.instance.primaryFocus?.unfocus();

  ///   [selectItemFromList] method is used to update selected item in a list
  ///   where selection on one item is allowed only
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

  ///   [validateForm] method is to validate form by its key
  static bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState!.validate();
  }

  ///   [formatDate] method is used to format date given date in more understandable format
  static String formatDate(DateTime selectedDate) {
    return DateFormat('dd-MMM-yyyy').format(selectedDate).toString();
  }

  ///   [calculateDifference] method is used to calculate difference between current date and given date
  static int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  ///   [showLoading] method returns UI component to represent loading
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

  ///   [showErrorMessage] method returns UI component that is used to display
  ///   some error that might occur in expected places
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