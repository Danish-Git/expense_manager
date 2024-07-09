import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/constants/app_config.dart';
import '../../../../app/themes/index.dart';

Future<dynamic> getDialog({
  required Widget child,
  bool allowFullWidth = false,
  bool enableInsets = false,
}) async {
  return await Get.dialog(
      Center(
        child: AnimatedPadding(
          padding: !enableInsets
              ? EdgeInsets.zero
              : const EdgeInsets.only(bottom: 20) + const EdgeInsets.only(bottom: 20),
          duration: const Duration(milliseconds: 50),
          child: Container(
            constraints: allowFullWidth
              ? null
              : const BoxConstraints(maxWidth: 550, minWidth: 550, maxHeight: 800),
            child: Material(
              color: EMAppTheme.themeColors.transparent,
              child: child,
            ),
          ),
        ),
      ),
    transitionDuration: const Duration(milliseconds: AppConfig.transitionDuration),
  );
}