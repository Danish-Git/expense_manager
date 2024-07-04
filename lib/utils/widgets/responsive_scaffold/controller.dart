import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/models/data_models/expense.dart';
import '../../../screens/forms/add_expense/index.dart';
import '../bottom_sheet/index.dart';

class ResponsiveScaffoldController extends GetxController with GetSingleTickerProviderStateMixin {


  late AnimationController articleIconSlideController;

  ValueNotifier<bool?> showGridView = ValueNotifier<bool?>(false);

  final Function(ExpenseModel? expense)? onAddExpense;

  ResponsiveScaffoldController({this.onAddExpense});

  @override
  void onInit() {
    super.onInit();
    showGridView.addListener(() => articleIconSlideController..reset()..forward());

    articleIconSlideController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    )..forward();

  }

  Future<void> addExpense(bool isMobile) async {
    ExpenseModel? expense = await getBottomSheet(
      isMobile: isMobile,
      child: const ExpenseFormView(),
    );

    onAddExpense?.call(expense);
  }

}