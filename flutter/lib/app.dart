import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';

class IntelligenceApp extends StatelessWidget {
  const IntelligenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Expense Manager',
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
