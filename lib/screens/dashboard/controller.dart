import 'package:expense_manager/common/repositories/category.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/providers/notification/controller.dart';
import '../../utils/global_widgets/text/index.dart';
import '../history/index.dart';
import '../settings/index.dart';

class DashboardController extends GetxController {
  ///   [selectedIndex] is used to hold the value of index of selected bottom
  ///   navigation bar in case of mobile view and index of selected item from
  ///   menu items in case of tablet view
  int selectedIndex = 0;

  ///   [mainDrawerItems] is a getter that provide list of menu items used in
  ///   case of tablet view
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

  ///   [bottomNavigationItems] is a getter that provides list of bottom
  ///   navigation items used in case of mobile view
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
  ///   [loadData] method is used to load the data foe initial processing which
  ///   also include initializations of various necessary services or listeners
  ///   in over case it is notification listeners
  Future<void> loadData() async {
    NotificationController.startListeningNotificationEvents();
    await loadCategories();
  }

  ///   [loadCategories] method is used to load default categories in local BD
  Future<void> loadCategories() async {
    try {
      await CategoryRepository.loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  ///   [pages] is used for navigation purpose based on selected index
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

  ///   [onItemSelection] method is used to update the selected index of menu
  ///   item in case of tab view and index of bottom navigation item in case
  ///   of mobile view
  void onItemSelection(int? index) {
    selectedIndex = index ?? 0;
    update();
  }
}