import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/constants/app_config.dart';


Future<dynamic> getBottomSheet({
  required Widget child,
  required bool isMobile,
  bool isScrollControlled = false,
  bool ignoreSafeArea = true,
  bool isDismissible = true,
  bool enableDrag = false,
  bool allowFullWidth = false,
  bool enableInsets = false}) async {
    return await Get.bottomSheet(
      child,
      isScrollControlled: isScrollControlled,
      ignoreSafeArea: ignoreSafeArea,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      enterBottomSheetDuration: const Duration(milliseconds: AppConfig.transitionDuration),
      exitBottomSheetDuration: const Duration(milliseconds: AppConfig.transitionDuration),
    );
}