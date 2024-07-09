
import '../../data/models/ui_models/theme.dart';
import 'theme_colors.dart';

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