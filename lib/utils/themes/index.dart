import '../../common/models/ui_models/theme.dart';
import '../../common/models/ui_models/theme_colors.dart';

class EMAppTheme {
  static ThemeModel themeData = ThemeModel(
    colors: ThemeColors.light(),
  );

  static void setTheme(bool isDark) {
    if (isDark) {
      themeData = ThemeModel(
          colors: ThemeColors.dark(),
      );
    } else {
      themeData = ThemeModel(
          colors: ThemeColors.light(),
      );
    }
  }

  static ThemeColors get themeColors {
    return themeData.colors;
  }
}