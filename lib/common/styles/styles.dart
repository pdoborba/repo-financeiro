import 'package:flutter/material.dart';

TextStyle extend(TextStyle s1, TextStyle s2) {
  return s1.merge(s2);
}

class Styles {
  static const TextStyle titleStyle =
      TextStyle(fontSize: 24, color: Colors.black);

  static final bodyStyle = extend(titleStyle, const TextStyle(fontSize: 16));
}
