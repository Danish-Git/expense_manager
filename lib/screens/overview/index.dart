import 'package:expense_manager/utils/constants/app_config.dart';
import 'package:expense_manager/utils/themes/index.dart';
import 'package:expense_manager/utils/widgets/text/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller.dart';

class OverviewView extends StatelessWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OverviewController>(
      global: false,
      init: OverviewController(),
      builder: (controller) => SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: EMAppTheme.themeColors.lightGray,
            title: TextWidget(text: AppConfig.appName.tr),
            centerTitle: true,
          ),
          body: Container(
            color: EMAppTheme.themeColors.base,
          ),
        ),
      )
    );
  }
}
