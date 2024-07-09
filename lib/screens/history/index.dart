import 'package:expense_manager/utils/constants/app_config.dart';
import 'package:expense_manager/utils/themes/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:get/get.dart';
import '../../utils/global_widgets/button/constants/button_type.dart';
import '../../utils/global_widgets/button/inidex.dart';
import '../../utils/global_widgets/text/constants/font_size.dart';
import '../../utils/global_widgets/text/constants/font_weight.dart';
import '../../utils/global_widgets/text/index.dart';
import '../../utils/helpers/helper.dart';
import 'controller.dart';
import 'widget/list_item_tile.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key,});


  @override
  Widget build(BuildContext context) {
    return GetBuilder<HistoryController>(
      global: false,
      init: HistoryController(),
      builder: (controller) => SafeArea(
        child: Scaffold(
          backgroundColor: EMAppTheme.themeColors.base,
          appBar: AppBar(
            backgroundColor: EMAppTheme.themeColors.lightGray,
            title: TextWidget(
              text: "history".tr,
              color: EMAppTheme.themeColors.text,
              fontWeight: EMFontWeight.bold,
            ),
            centerTitle: true,
          ),
          body: controller.isLoading
            ? Center(child: Helper.showLoading())
            : controller.historyList?.isEmpty ?? true
              ? Center(child: Helper.showErrorMessage())
              : ListView.builder(
            itemCount: controller.historyList?.length ?? 0,
            addAutomaticKeepAlives: false,
            itemBuilder: (BuildContext context, int index) {

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget(
                            text: controller.getFormattedDate(controller.historyList?[index].date ?? ""),
                            fontSize: EMFontSize.title,
                            fontWeight: EMFontWeight.bold,
                          ),
                          TextWidget(
                            text: "${AppConfig.rupeeSymbol} ${controller.historyList?[index].total.toString() ?? ""}",
                            color: EMAppTheme.themeColors.primary,
                            fontSize: EMFontSize.title,
                            fontWeight: EMFontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                    for (var element in controller.historyList![index].items!)...{
                      HistoryListItemTile(
                        expense: element!,
                        onTap: () => controller.addEditExpense(isMobile:!Breakpoints.mediumAndUp.isActive(context), expenseModel: element)
                      ),
                      const SizedBox(height: 5)
                    },
                    Visibility(
                      visible: index + 1 == (controller.historyList?.length ?? 0),
                      child: const SizedBox(height: 100)
                    ),
                  ],
                ),
              );
            }
          ),
            floatingActionButton: Visibility(
              visible: !Breakpoints.mediumAndUp.isActive(context),
              child: CustomButton(
                buttonType: ButtonType.small,
                leadingIcon: const Icon(Icons.add),
                onTap: () => controller.addEditExpense(isMobile: !Breakpoints.mediumAndUp.isActive(context)),
              ),
            )
        ),
      )
    );
  }
}
