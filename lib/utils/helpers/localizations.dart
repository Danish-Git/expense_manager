
import 'package:expense_manager/utils/constants/app_config.dart';
import 'package:expense_manager/utils/enums/localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationsHelper {

  static String getSelectedLocaleName(Languages? language) {
    switch(language) {
      case Languages.english:
        return "English";
      case Languages.urdu:
        return "Urdu";
      default:
        return "English";
    }
  }

  static Locale getSelectedLocale(Languages language) {
    switch(language) {
      case Languages.english:
        return AppConfig.englishLocale;
      case Languages.urdu:
        return AppConfig.urduLocale;
    }
  }

  static Languages getSharedPreferencesLocale(String? language) {
    switch(language) {
      case "Languages.english":
        return Languages.english;
      case "Languages.urdu":
        return Languages.urdu;
      default:
        return Languages.english;
    }
  }

  static Future<void> changeLocale(Locale locale) async => await Get.updateLocale(locale);



}