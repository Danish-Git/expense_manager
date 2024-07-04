import 'package:expense_manager/utils/enums/localizations.dart';
import 'package:expense_manager/utils/helpers/localizations.dart';
import 'package:expense_manager/utils/helpers/shared_preferences.dart';
import 'package:get/get.dart';

import '../../routes/routes.dart';
import '../../utils/constants/shared_preferences.dart';

class SettingController extends GetxController {

  Languages? selectedLanguage;

  String get getSelectedLanguageName => LocalizationsHelper.getSelectedLocaleName(selectedLanguage);

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

  Future<void> logout() async {
    await SharedPreferencesHelper().removeAll();
    Get.offAllNamed(Routes.splash);
  }
}