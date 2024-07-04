import 'package:expense_manager/utils/themes/index.dart';
import 'package:expense_manager/utils/widgets/text/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'constants/button_type.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.buttonType,
    this.title,
    this.leadingIcon,
    this.onTap,
  });

  final ButtonType buttonType;
  final String? title;
  final Widget? leadingIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: EMAppTheme.themeColors.dimGray,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: buttonType == ButtonType.small
          ? small()
          : buttonType == ButtonType.medium
            ? small()
            : buttonType == ButtonType.large
              ? large(context)
              : small()
      ),
    );
  }

  Widget small () => SizedBox(
    width: 50, height: 50,
    child: leadingIcon,
  );

  Widget medium () => Column(
    children: [
      Container(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
        child: leadingIcon,
      ),
      small(),
  ]);

  Widget large (context) => Container(
    alignment: Alignment.center,
    width: leadingIcon != null ? 200 : 150,
    height: 50,
    padding: leadingIcon != null ? const EdgeInsets.only(left: 16) : const EdgeInsets.all(10),
    child: leadingIcon != null ? Row(
      children: [
        leadingIcon!,
        const SizedBox(width: 20),
        Center(child: TextWidget(text: title ?? "record_expense".tr)),
      ],
    ) : TextWidget(text: title ?? "save".tr.toUpperCase()),
  );
}