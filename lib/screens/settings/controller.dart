import 'package:expense_manager/utils/enums/localizations.dart';
import 'package:expense_manager/utils/helpers/localizations.dart';
import 'package:expense_manager/utils/helpers/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../common/providers/notification/index.dart';
import '../../routes/routes.dart';
import '../../utils/constants/shared_preferences.dart';

class SettingController extends GetxController {

  Languages? selectedLanguage;

  TimeOfDay? selectedTime;

  String get getSelectedLanguageName => LocalizationsHelper.getSelectedLocaleName(selectedLanguage);

  String get getSelectedTime {
    DateTime now = DateTime.now();
    if(selectedTime == null) {
      return "select_time".tr;
    } else {
      return DateFormat("h:mm a").format(DateTime(now.year, now.month, now.day, selectedTime!.hour, selectedTime!.minute));
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    String? language = await SharedPreferencesHelper().read(PrefConstants.locale);
    selectedLanguage = LocalizationsHelper.getSharedPreferencesLocale(language);
    update();
  }

  Future<void> changeLocale(Languages language) async {
    selectedLanguage = language;
    await LocalizationsHelper.changeLocale(LocalizationsHelper.getSelectedLocale(selectedLanguage!));
    await SharedPreferencesHelper().save(PrefConstants.locale, selectedLanguage.toString());
    update();
  }

  void selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      selectedTime = pickedTime;
      setReminder();
    }
    update();
  }



  Future<void> logout() async {
    await SharedPreferencesHelper().removeAll();
    Get.offAllNamed(Routes.splash);
  }

  void setReminder() {
    var scheduledDate = DateTime.now();
    debugPrint('Notification Scheduled for $selectedTime');
    NotificationProvider.createNewNotification(DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day, selectedTime!.hour, selectedTime!.minute));
  }


}