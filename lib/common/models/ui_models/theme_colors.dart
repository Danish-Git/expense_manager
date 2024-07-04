
import 'package:flutter/material.dart';

class ThemeColors {
  Color base;
  Color primary;
  Color secondary;
  Color text;
  Color secondaryText;
  Color success;
  Color warning;
  Color lightGray;
  Color dimGray;
  Color darkGray;
  Color lightBlue;
  Color red;
  Color transparent;

  ThemeColors.light({
    this.base = const Color(0xffffffff),
    this.primary = const Color(0xff418BCA),
    this.secondary = const Color(0xff2E2E2E),
    this.text = const Color(0xff222326),
    this.secondaryText = const Color(0xff9ca2b0),
    this.success = const Color(0xff42BA96),
    this.warning = const Color(0xffFFA115),
    this.lightGray = const Color(0xffE9EBEF),
    this.dimGray = const Color(0xffE0E0E0),
    this.darkGray = const Color(0xff888888),
    this.lightBlue = const Color(0xffdae5ff),
    this.red = const Color(0xffDC4437),
    this.transparent = Colors.transparent
  });

  ThemeColors.dark({
    this.base = const Color(0xffffffff),
    this.primary = const Color(0xff418BCA),
    this.secondary = const Color(0xff2E2E2E),
    this.text = const Color(0xff222326),
    this.secondaryText = const Color(0xff9ca2b0),
    this.success = const Color(0xff42BA96),
    this.warning = const Color(0xffFFA115),
    this.lightGray = const Color(0xffE9EBEF),
    this.dimGray = const Color(0xffE0E0E0),
    this.darkGray = const Color(0xff888888),
    this.lightBlue = const Color(0xffdae5ff),
    this.red = const Color(0xffDC4437),
    this.transparent = Colors.transparent,
  });
}