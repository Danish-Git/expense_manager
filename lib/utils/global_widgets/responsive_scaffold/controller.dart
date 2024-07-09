import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/models/data_models/expense.dart';
import '../../../screens/forms/add_expense/index.dart';
import '../bottom_sheet/index.dart';

class ResponsiveScaffoldController extends GetxController with GetSingleTickerProviderStateMixin {

  ///   [articleIconSlideController] is used to control animation of menu items
  ///   in case of tab view and bottom navigation bar items in case of mobile view
  late AnimationController articleIconSlideController;

  @override
  void onInit() {
    super.onInit();

    ///   initialization of animation controller
    articleIconSlideController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    )..forward();

  }

  ///   [addExpense] method is used to add expense, This method is used only in
  ///   case of tablet view where user can clicks on add expense button available in menu items
  Future<void> addExpense(bool isMobile) async {
    ExpenseModel? expense = await getBottomSheet(
      isMobile: isMobile,
      child: const ExpenseFormView(),
    );

    if(expense != null) {
      refresh();
    }
  }

}