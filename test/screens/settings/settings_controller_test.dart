import 'package:expense_manager/screens/settings/controller.dart';
import 'package:expense_manager/utils/enums/localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  SettingController controller = SettingController();

  group("SettingController@getSelectedLanguageName, Should provide correct name of selected language", () {

    test('Should provide correct language name for when english is selected', () {
      controller.selectedLanguage = Languages.english;
      expect(controller.getSelectedLanguageName, equals('english'.tr));
    });

    test('Should provide correct language name for when urdu is selected', () {
      controller.selectedLanguage = Languages.urdu;
      expect(controller.getSelectedLanguageName, equals('urdu'.tr));
    });

    test('Should provide default language name for when no language is selected', () {
      controller.selectedLanguage = null;
      expect(controller.getSelectedLanguageName, equals('english'));
    });
  });
}