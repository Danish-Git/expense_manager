import 'package:expense_manager/utils/constants/app_config.dart';
import 'package:expense_manager/utils/themes/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/global_widgets/text/constants/font_size.dart';
import '../../utils/global_widgets/text/constants/font_weight.dart';
import '../../utils/global_widgets/text/index.dart';
import 'controller.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      global: false,
      init: SplashController(),
      builder: (controller) => Scaffold(
        body: SafeArea(
          child: SizedBox(
            height: double.maxFinite,
            width: double.maxFinite,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.currency_exchange_outlined,
                  color: EMAppTheme.themeColors.primary,
                  size: 100),

                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextWidget(
                    text: AppConfig.appName.tr,
                    fontSize: EMFontSize.title,
                    fontWeight: EMFontWeight.bold,
                    fontStyle: FontStyle.italic
                  ),
                )
              ],
            ),
          ),
        ),
      ),

    );
  }
}
