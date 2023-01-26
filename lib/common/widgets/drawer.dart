import 'package:flutter/material.dart';
import 'package:lpcapital/auth/auth_repository.dart';
import 'package:lpcapital/login/login_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../colors.dart';

enum DrawerItens { LOGOUT }

class DrawerWidget extends StatefulWidget {
  final Function(DrawerItens item) callback;

  DrawerWidget({Key? key, required this.callback}) : super(key: key);

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  PackageInfo _packageInfo = PackageInfo(
    appName: '-',
    packageName: '-',
    version: '-',
    buildNumber: '-',
    buildSignature: '-',
  );

  @override
  void initState() {
    _initPackageInfo();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 32, top: 64),
      color: AppColors.PRIMARY_COLOR,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: () => _onClick(DrawerItens.LOGOUT),
              child: const Text(
                'Sair',
                style: TextStyle(color: Colors.white, fontSize: 24),
              )),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _packageInfo.version,
                style: TextStyle(color: Colors.white, fontSize: 24),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void _onClick(DrawerItens item) async {
    switch (item) {
      case DrawerItens.LOGOUT:
        var authRepository = AuthRepository();
        await authRepository.logout();
        // if (!context.mounted) return;
        await Navigator.pushReplacementNamed(context, LoginPage.routeName);
        break;
    }
  }
}
