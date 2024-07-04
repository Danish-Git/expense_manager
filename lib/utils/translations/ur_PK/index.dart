import 'helpers/form_validator.dart';
import 'screens/add_expense_form.dart';
import 'screens/dashboard.dart';
import 'screens/history.dart';
import 'screens/settings.dart';
import 'screens/splash.dart';

class UrPkTranslationStrings {
  static Map<String, String> allStrings = {
    ...UrPkDashboardTranslations.strings,
    ...UrPkAddExpenseFormTranslations.strings,
    ...UrPkHistoryTranslations.strings,
    ...UrPkSettingsTranslations.strings,
    ...UrPkSplashTranslations.strings,
    ...UrPkFormValidatorTranslations.strings,
  };
}