import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/constants/shared_preferences.dart';
import '../../../app/enums/localizations.dart';
import '../../../app/helpers/localizations.dart';
import '../../../app/helpers/shared_preferences.dart';
import '../../../app/routes/routes.dart';
import '../../../domain/notification/index.dart';

class SettingController extends GetxController {

  ///   [selectedLanguage] is used to hold the value of selected language
  Languages? selectedLanguage;

  ///   [selectedTime] is used to hold the value of selected time ofr notification
  TimeOfDay? selectedTime;

  ///   [getSelectedLanguageName] is getter used to get the name fo the selected language
  String get getSelectedLanguageName => LocalizationsHelper.getSelectedLocaleName(selectedLanguage);

  ///   [getSelectedTime] is a getter used to format the selected time to 12 hour format
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

  ///   [loadData] method is use to load the initial data uses to represent information's on setting screen
  Future<void> loadData() async {
    String? language = await SharedPreferencesHelper().read(PrefConstants.locale);
    selectedLanguage = LocalizationsHelper.getSharedPreferencesLocale(language);
    update();
  }

  ///   [changeLocale] method is used to change the language and also updates the localizations of the app
  Future<void> changeLocale(Languages language) async {
    selectedLanguage = language;
    await LocalizationsHelper.changeLocale(LocalizationsHelper.getSelectedLocale(selectedLanguage!));
    await SharedPreferencesHelper().save(PrefConstants.locale, selectedLanguage.toString());
    update();
  }

  ///   [selectedTime] method is used to open the time picker and update the
  ///   selected time ofr notification scheduling
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

  ///   [setReminder] method is used to send the reminder on the selected time
  void setReminder() {
    var scheduledDate = DateTime.now();
    debugPrint('Notification Scheduled for $selectedTime');
    NotificationProvider.createNewNotification(DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day, selectedTime!.hour, selectedTime!.minute));
  }

  ///   [logout] method is used to log out and clear the shared preferences
  Future<void> logout() async {
    await SharedPreferencesHelper().removeAll();
    Get.offAllNamed(Routes.splash);
  }

}