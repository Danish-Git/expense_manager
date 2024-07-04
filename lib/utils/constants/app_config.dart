import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppConfig {
  static const String appName = "expense_manager";
  static const int transitionDuration = 150;
  static const String amountReg = r'^\d*\.?\d{0,2}';
  static const String rupeeSymbol = "\u20B9";
  static const Locale englishLocale = Locale('en', 'US');
  static const Locale urduLocale = Locale('ur', 'PK');
  static const Duration maxExpenseManagementDuration = Duration(days: 7);
}