
import 'package:expense_manager/utils/constants/app_config.dart';
import 'package:expense_manager/utils/enums/localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationsHelper {

  ///   [getSelectedLocaleName] method returns name of the given language
  static String getSelectedLocaleName(Languages? language) {
    switch(language) {
      case Languages.english:
        return "english".tr;
      case Languages.urdu:
        return "urdu".tr;
      default:
        return "english".tr;
    }
  }

  ///   [getSelectedLocale] method provides locale object for the given language
  static Locale getSelectedLocale(Languages language) {
    switch(language) {
      case Languages.english:
        return AppConfig.englishLocale;
      case Languages.urdu:
        return AppConfig.urduLocale;
    }
  }

  ///   [getSharedPreferencesLocale] this method is used to get the language
  ///   enum from the date data stored in shared preferences
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

  ///   [changeLocale] method is used to change the localization of the app
  static Future<void> changeLocale(Locale locale) async => await Get.updateLocale(locale);
}