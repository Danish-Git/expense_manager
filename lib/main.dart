import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'common/models/ui_models/app_translations.dart';
import 'routes/index.dart';
import 'routes/routes.dart';
import 'utils/constants/app_config.dart';

void main() {
  runApp(const ExpenseManager());
}

class ExpenseManager extends StatelessWidget {
  const ExpenseManager ({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      defaultTransition: Transition.leftToRight,
      fallbackLocale: const Locale('en', 'US'),
      getPages: AppPages.pages,
      initialRoute: Routes.splash,
    );
  }
}

