import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/themes/index.dart';
import '../text/constants/font_size.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.textController,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.readOnly = false,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onTap,
  });

  final TextEditingController textController;
  final String labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final bool? readOnly;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<dynamic>? validator;
  final VoidCallback? onTap;


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      onChanged: (value) {},
      onTap: onTap,
      readOnly: readOnly ?? false,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      style: TextStyle(
        color: EMAppTheme.themeColors.text,
        fontSize: EMFontSize.text,
      ),
      decoration: InputDecoration(
        focusColor: EMAppTheme.themeColors.base,
        fillColor: EMAppTheme.themeColors.base,
        hintText: hintText,
        labelText: labelText,
        //add prefix icon
        prefixIcon: prefixIcon,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide:  BorderSide(color: EMAppTheme.themeColors.text, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),

        hintStyle: TextStyle(
          color: EMAppTheme.themeColors.text,
          fontSize: EMFontSize.text,
        ),

        labelStyle: TextStyle(
          color: EMAppTheme.themeColors.text,
          fontSize: EMFontSize.text,
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }
}
