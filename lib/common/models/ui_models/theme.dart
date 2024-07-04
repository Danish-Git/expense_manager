
import 'package:expense_manager/common/models/ui_models/theme_colors.dart';

import '../../../utils/helpers/form_ui_helper.dart';

class ThemeModel {
  ThemeModel({
    required this.colors,
    required this.formUiHelper,
  });

  ThemeColors colors;

  FormUiHelper formUiHelper;

}