import 'package:get/get.dart';

import '../../routes/routes.dart';
import '../../utils/constants/shared_preferences.dart';
import '../../utils/enums/localizations.dart';
import '../../utils/helpers/localizations.dart';
import '../../utils/helpers/shared_preferences.dart';

class SplashController extends GetxController {

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  ///   [loadData] method is used to load initial data
  Future<void> loadData() async {
    await setLocalizations();
    Future.delayed(const Duration(seconds: 3), () => navigateToScreen());
  }

  ///   [navigateToScreen] method is used to redirect users to other screen as
  ///   soon as initial data is loaded successfully
  void navigateToScreen() {
    Get.offAllNamed(Routes.dashboard);
  }

  ///   [setLocalizations] method is used to set the localizations of the app.
  ///   If user haven't selected any preferred language then default english
  ///   language is selected for localization
  Future<void> setLocalizations() async {
    String? language = await SharedPreferencesHelper().read(PrefConstants.locale);
    Languages? selectedLanguage = LocalizationsHelper.getSharedPreferencesLocale(language);
    await LocalizationsHelper.changeLocale(LocalizationsHelper.getSelectedLocale(selectedLanguage));
    await SharedPreferencesHelper().save(PrefConstants.locale, selectedLanguage.toString());
  }
}