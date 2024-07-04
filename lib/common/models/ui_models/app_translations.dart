import 'package:get/get.dart';

import '../../../utils/translations/en_US/index.dart';


class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': EnUsTranslationStrings.allStrings,
    // 'ur_PK': UrPkTranslationStrings.allStrings,
  };
}