import 'package:expense_manager/common/models/data_models/expense.dart';
import 'package:expense_manager/common/repositories/category.dart';
import 'package:expense_manager/utils/widgets/text/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/providers/notification/controller.dart';
import '../history/index.dart';
import '../settings/index.dart';

class DashboardController extends GetxController {
  int selectedIndex = 0;

  ExpenseModel? expense;

  List<NavigationRailDestination> get mainDrawerItems => <NavigationRailDestination>[
    NavigationRailDestination(
      icon: const Icon(Icons.history),
      label: TextWidget(text: "history".tr),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.settings),
      label: TextWidget(text: "settings".tr),
    )
  ];

  List<NavigationDestination> get bottomNavigationItems => <NavigationDestination>[
    NavigationDestination(
      label: 'history'.tr,
      icon: const Icon(Icons.history),
    ),
    NavigationDestination(
      label: 'settings'.tr,
      icon: const Icon(Icons.settings),
    )
  ];

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    NotificationController.startListeningNotificationEvents();
    await loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      await CategoryRepository.loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  Widget pages (index) {
    switch(index) {
      case 0:
        return const HistoryView();
      case 1:
        return const SettingView();
      default:
        return Container();
    }
  }

  void onItemSelection(int? index) {
    selectedIndex = index ?? 0;
    update();
  }
}