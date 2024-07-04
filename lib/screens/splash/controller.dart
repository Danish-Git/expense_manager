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

  Future<void> loadData() async {
    await setLocalizations();
    Future.delayed(const Duration(seconds: 3), () => navigateToScreen());
  }

  void navigateToScreen() {
    Get.offAllNamed(Routes.dashboard);
  }

  Future<void> setLocalizations() async {
    String? language = await SharedPreferencesHelper().read(PrefConstants.locale);
    Languages? selectedLanguage = LocalizationsHelper.getSharedPreferencesLocale(language);
    await LocalizationsHelper.changeLocale(LocalizationsHelper.getSelectedLocale(selectedLanguage));
    await SharedPreferencesHelper().save(PrefConstants.locale, selectedLanguage.toString());
  }
}