import 'package:flutter/material.dart';

import '../../home/home_page.dart';

///AppBarWidget
// ignore: prefer_mixin
class AppBarWidget extends StatelessWidget with PreferredSizeWidget {
  ///AppBarWidget
  AppBarWidget({
    Key? key,
    this.bgColor,
    this.preferredSize = const Size.fromHeight(70),
    this.iconColor,
    this.hasClose = true,
    this.backCallback,
    this.closeCallback,
    this.hasBack = true,
    this.hasIcon = true,
    this.hasDrawer = false,
  }) : super(key: key);

  @override
  final Size preferredSize;

  final bool hasClose;

  final bool hasBack;
  final bool hasDrawer;

  final Color? bgColor;

  final Color? iconColor;

  final bool hasIcon;

  final VoidCallback? backCallback;
  final VoidCallback? closeCallback;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      elevation: 0,
      actions: [
        hasDrawer == true
            ? Builder(builder: (context) {
                return IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    });
              })
            : SizedBox.shrink(),
        hasClose
            ? Builder(builder: (context) {
                return IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    });
              })
            : const SizedBox()
      ],
      backgroundColor: bgColor,
      leading: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16),
        child: Row(children: [
          hasBack
              ? GestureDetector(
                  onTap: () => _back(context),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 25,
                    color: iconColor ?? Colors.white,
                  ),
                )
              : const SizedBox(),
          hasIcon
              ? const Image(
                  image: AssetImage('assets/ic_app_bar_logo.png'),
                )
              : const SizedBox()
        ]),
      ),
    );
  }

  void _back(BuildContext context) async {
    if (backCallback != null) {
      backCallback!();
    } else {
      Navigator.pop(context);
    }
  }
}
