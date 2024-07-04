import 'package:flutter/material.dart';
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
}