import '../../common/models/ui_models/theme.dart';
import '../../common/models/ui_models/theme_colors.dart';
import '../helpers/form_ui_helper.dart';

class EMAppTheme {
  static ThemeModel themeData = ThemeModel(
    colors: ThemeColors.light(),
    formUiHelper: FormUiHelper(),
  );

  static void setTheme(bool isDark) {
    if (isDark) {
      themeData = ThemeModel(
          colors: ThemeColors.dark(),
          formUiHelper: FormUiHelper()
      );
    } else {
      themeData = ThemeModel(
          colors: ThemeColors.light(),
          formUiHelper: FormUiHelper()
      );
    }
  }

  static ThemeColors get themeColors {
    return themeData.colors;
  }

  static FormUiHelper get formUiHelper {
    return themeData.formUiHelper;
  }
}