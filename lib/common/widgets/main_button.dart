import 'package:flutter/material.dart';

import '../colors.dart';

///Button
class MainButton extends StatelessWidget {
  const MainButton(
      {Key? key,
      required this.message,
      required this.callback,
      this.height = 25})
      : super(key: key);

  final String message;
  final VoidCallback? callback;
  final double height;

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration;
    if (callback != null) {
      decoration = const BoxDecoration(
          color: AppColors.BUTTON_COLOR,
          borderRadius: BorderRadius.all(Radius.circular(24)));
    } else {
      decoration = const BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(24)));
    }

    return InkWell(
        onTap: callback,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          decoration: decoration,
          height: 45,
          child: Text(message,
              style: const TextStyle(fontSize: 18, color: Colors.white)),
        ));
  }
}
