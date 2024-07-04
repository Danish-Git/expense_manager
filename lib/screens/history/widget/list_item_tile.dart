import 'package:expense_manager/common/models/data_models/expense.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/app_config.dart';
import '../../../utils/themes/index.dart';
import '../../../utils/widgets/text/constants/font_size.dart';
import '../../../utils/widgets/text/constants/font_weight.dart';
import '../../../utils/widgets/text/index.dart';

class HistoryListItemTile extends StatelessWidget {
  const HistoryListItemTile({
    super.key,
    required this.expense,
    required this.onTap
  });

  final ExpenseModel expense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: EMAppTheme.themeColors.lightGray,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    expense.category?.icon,
                    size: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: expense.category?.name ?? "",
                          fontSize: EMFontSize.subTitle,
                        ),
                        Visibility(
                          visible: expense.description?.isNotEmpty ?? false,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: TextWidget(
                              text: expense.description ?? "",
                              fontSize: EMFontSize.subText,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              TextWidget(
                text: "${AppConfig.rupeeSymbol}  ${expense.amount ?? ""}",
                fontSize: EMFontSize.title,
                fontWeight: EMFontWeight.normal,
              )
            ],
          ),
        ),
      ),
    );
  }
}
