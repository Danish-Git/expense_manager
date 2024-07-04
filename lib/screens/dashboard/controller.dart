import 'package:expense_manager/common/models/data_models/expense.dart';
import 'package:expense_manager/common/repositories/category.dart';
import 'package:expense_manager/utils/widgets/text/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../history/index.dart';
import '../overview/index.dart';
import '../settings/index.dart';

class DashboardController extends GetxController {
  int selectedIndex = 0;

  ExpenseModel? expense;

  List<NavigationRailDestination> get mainDrawerItems => const <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.account_balance_wallet_rounded),
      label: TextWidget(text: "Overview"),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.history),
      label: TextWidget(text: "History"),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings),
      label: TextWidget(text: "Settings"),
    )
  ];

  List<NavigationDestination> get bottomNavigationItems => const <NavigationDestination>[
    NavigationDestination(
      label: 'Overview',
      icon: Icon(Icons.account_balance_wallet_rounded),
    ),
    NavigationDestination(
      label: 'History',
      icon: Icon(Icons.history),
    ),
    NavigationDestination(
      label: 'Settings',
      icon: Icon(Icons.settings),
    )
  ];

  Widget pages (index) {
    switch(index) {
      case 0:
        return const OverviewView();
      case 1:
        return HistoryView(expense: expense);
      case 2:
        return const SettingView();
      default:
        return Container();
    }
  }


  void onItemSelection(int? index) {
    selectedIndex = index ?? 0;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    await loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      await CategoryRepository.loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  void onAddExpense(ExpenseModel? expense) {
    this.expense = expense;
    refresh();
  }
}