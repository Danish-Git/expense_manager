import 'package:expense_manager/common/models/data_models/expense.dart';
import 'package:expense_manager/utils/constants/app_config.dart';
import 'package:expense_manager/utils/widgets/button/inidex.dart';
import 'package:expense_manager/utils/widgets/text/constants/font_weight.dart';
import 'package:expense_manager/utils/widgets/text/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:get/get.dart';

import '../../../utils/helpers/form_validator.dart';
import '../../../utils/themes/index.dart';
import '../../../utils/widgets/button/constants/button_type.dart';
import '../../../utils/widgets/text/constants/font_size.dart';
import '../../../utils/widgets/text_form_field/index.dart';
import 'controller.dart';

class ExpenseFormView extends StatelessWidget {
  const ExpenseFormView({
    super.key,
    this.expense
  });

  final ExpenseModel? expense;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseFormController>(
      global: false,
      init: ExpenseFormController(expense: expense),
      dispose: (GetBuilderState<ExpenseFormController> state) => state.controller?.dispose,
      builder: (controller) => Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.90),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          color: EMAppTheme.themeColors.lightGray,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ///   Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        text: "record_expense".tr,
                        fontSize: EMFontSize.title,
                        fontWeight: EMFontWeight.bold,
                      ),
                      IconButton(
                        onPressed: () => Get.back(result: null),
                        icon: Icon(Icons.close, color: EMAppTheme.themeColors.text, size: 18))
                    ],
                  ),
                  ///   Body
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Form(
                              key: controller.formKey,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          flex: 1,
                                          child: CustomTextFormField(
                                            textController: controller.amountInput,
                                            labelText: 'amount'.tr,
                                            hintText: "amount".tr,
                                            readOnly: !controller.isEditingAllowed,
                                            prefixIcon: Icon(
                                              Icons.account_balance_wallet,
                                              color: EMAppTheme.themeColors.text,
                                            ),
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(AppConfig.amountReg))],
                                            validator:(val) => FormValidator.validateAmount(val, isNumberRequired: true),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          flex: 1,
                                          child: CustomTextFormField(
                                            textController: controller.dateInput,
                                            onTap: controller.isEditingAllowed ? () => controller.selectDate(context) : null,
                                            readOnly: true,
                                            labelText: 'date'.tr,
                                            prefixIcon: Icon(
                                              Icons.calendar_month,
                                              color: EMAppTheme.themeColors.text,
                                            ),
                                            keyboardType: TextInputType.datetime,
                                            validator:(val) => FormValidator.requiredFieldValidator(val, errorMsg: "Please Select Date"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: CustomTextFormField(
                                      textController: controller.descriptionInput,
                                      minLines: 1,
                                      maxLines: 3,
                                      maxLength: 200,
                                      labelText: 'description'.tr,
                                      readOnly: !controller.isEditingAllowed,
                                    ),
                                  ),
                                ],
                              )
                          ),

                          if(controller.categories?.isNotEmpty ?? false)...{
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TextWidget(
                                text: controller.isCategorySelected ? "select_expense_category".tr : "please_select_expense_category".tr,
                                color: controller.isCategorySelected ? EMAppTheme.themeColors.text: EMAppTheme.themeColors.red,
                                fontSize: EMFontSize.text ,
                                fontWeight: EMFontWeight.bold,
                              ),
                            ),

                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: (!Breakpoints.mediumAndUp.isActive(context)) ? 4 : 5),
                              itemCount: controller.categories?.length ?? 0,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Material(
                                    borderRadius: BorderRadius.circular(20),
                                    color: controller.categories![index].isSelected ? EMAppTheme.themeColors.base : EMAppTheme.themeColors.dimGray,
                                    child: InkWell(
                                      onTap: controller.isEditingAllowed ? () => controller.selectCategory(index) : null,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: GridTile(
                                            footer: Center(
                                                child: TextWidget(
                                                  text: controller.categories?[index].name ?? "",
                                                  color: EMAppTheme.themeColors.text,
                                                  fontSize: EMFontSize.subText,
                                                  fontWeight: EMFontWeight.normal,
                                                )
                                            ),
                                            child: Icon(controller.categories?[index].icon)
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          },
                        ],
                      ),
                    ),
                  ),
                  ///   Footer
                  Visibility(
                    visible: controller.isEditingAllowed,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if(controller.isEditForm)...{
                              CustomButton(
                                title: "delete".tr.toUpperCase(),
                                buttonType: ButtonType.large,
                                onTap: controller.deleteExpense,
                              ),
                              const SizedBox(width: 10),
                            },
                            CustomButton(
                              buttonType: ButtonType.large,
                              onTap: controller.validateForm,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
