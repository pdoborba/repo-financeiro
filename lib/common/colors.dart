import 'package:flutter/material.dart';

// ignore: avoid_classes_with_only_static_members
class AppColors {
  // ignore: constant_identifier_names
  static const BG_COLOR = Colors.white;
  // ignore: constant_identifier_names
  static const PRIMARY_COLOR = Color(0xffB9161C);
  // ignore: constant_identifier_names
  static const SECONDARY_COLOR = Color(0xff0078B7);
  // ignore: constant_identifier_names
  static const DRAWER_SELECTED_COLOR = Color(0xff249EB2);
  // ignore: constant_identifier_names
  static const BUTTON_COLOR = Color(0xffB9161C);

  // Colors
  static const Color mainColor = Color(0xff31b0ba);
  static const Color secondColor = Color.fromRGBO(36, 158, 178, 1.0);
  static const Color thirdColor = Color.fromRGBO(91, 194, 180, 1.0);
  static const Color disabledColor = Color(0xff2d929b);

  // ignore: constant_identifier_names
  static const LINEAR_HORIZONTAL_GRADIENT = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xff249EB2), Color(0xff65C2AF)],
  );

  // ignore: constant_identifier_names
  static const LINEAR_VERTICAL_GRADIENT = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xff249EB2), Color(0xff65C2AF)],
  );

  static int getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}
