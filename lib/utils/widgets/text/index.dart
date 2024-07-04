import 'package:flutter/material.dart';

import '../../themes/index.dart';
import 'constants/font_size.dart';
import 'constants/font_weight.dart';


class TextWidget extends StatelessWidget {
  const TextWidget({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.overflow
  });

  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? EMAppTheme.themeColors.text,
        fontSize: fontSize ?? EMFontSize.text,
        fontWeight: fontWeight ?? EMFontWeight.normal,
        fontStyle: fontStyle ?? FontStyle.normal,
        overflow: overflow ?? TextOverflow.visible
      )
    );
  }
}
