import 'helpers/form_validator.dart';
import 'screens/add_expense_form.dart';
import 'screens/dashboard.dart';
import 'screens/history.dart';
import 'screens/settings.dart';
import 'screens/splash.dart';

class EnUsTranslationStrings {
  static Map<String, String> allStrings = {
    ...EnUsDashboardTranslations.strings,
    ...EnUsAddExpenseFormTranslations.strings,
    ...EnUsHistoryTranslations.strings,
    ...EnUsSettingsTranslations.strings,
    ...EnUsSplashTranslations.strings,
    ...EnUsFormValidatorTranslations.strings,
  };
}