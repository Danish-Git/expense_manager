import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/enums/localizations.dart';
import '../../../app/helpers/localizations.dart';
import '../../../app/themes/index.dart';
import '../../global/widgets/text/constants/font_weight.dart';
import '../../global/widgets/text/index.dart';
import 'controller.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingController>(
      global: false,
      init: SettingController(),
      builder: (controller) => SafeArea(
        child: Scaffold(
          backgroundColor: EMAppTheme.themeColors.base,
          appBar: AppBar(
            backgroundColor: EMAppTheme.themeColors.lightGray,
            title: TextWidget(
              text: "settings".tr,
              color: EMAppTheme.themeColors.text,
              fontWeight: EMFontWeight.bold,
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 50),
                      child: CircleAvatar(
                        radius: 50,
                        child: Icon(
                            Icons.person,
                            size: 50,
                            color: EMAppTheme.themeColors.primary
                        ),
                      ),
                    ),

                    ///   Setting menu items
                    const Divider(),
                    ///   Language selector
                    ListTile(
                      leading: const Icon(Icons.translate_outlined),
                      title: TextWidget(
                        text: "language".tr,
                      ),
                      trailing: PopupMenuButton<Languages>(
                        onSelected: controller.changeLocale,
                        itemBuilder: (context) => [
                          PopupMenuItem<Languages>(
                            value: Languages.english,
                            child: TextWidget(
                              text: LocalizationsHelper.getSelectedLocaleName(Languages.english)
                            )
                          ),
                          PopupMenuItem<Languages>(
                            value: Languages.urdu,
                            child: TextWidget(
                              text: LocalizationsHelper.getSelectedLocaleName(Languages.urdu)
                            )
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border.all(color: EMAppTheme.themeColors.text),
                              borderRadius: BorderRadius.circular(15)
                          ),
                          child: TextWidget(
                            text: controller.getSelectedLanguageName,
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    ///   Reminder notification
                    ListTile(
                      leading: const Icon(Icons.notifications_active_outlined),
                      title: TextWidget(
                        text: "reminder".tr,
                      ),
                      trailing: Material(
                        borderRadius: BorderRadius.circular(15),
                        child: InkWell(
                          onTap: () => controller.selectTime(context),
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: EMAppTheme.themeColors.text),
                              borderRadius: BorderRadius.circular(15)
                            ),
                            child: TextWidget(
                              text: controller.getSelectedTime,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    ///   logout
                    ListTile(
                      onTap: controller.logout,
                      leading: const Icon(Icons.logout_outlined),
                      title: TextWidget(
                        text: "logout".tr,
                      ),
                      trailing: const Icon(Icons.navigate_next_outlined),
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}
