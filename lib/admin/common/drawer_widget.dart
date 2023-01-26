import 'package:flutter/material.dart';
import 'package:lpcapital/admin/deposit/deposit_page.dart';
import 'package:lpcapital/admin/withdraw/withdraw_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../auth/auth_repository.dart';
import '../../login/login_page.dart';
import '../user/users_page.dart';

///DrawerWidget
class DrawerWidget extends StatefulWidget {
  const DrawerWidget({
    Key? key,
  }) : super(key: key);

  @override
  DrawerWidgetState createState() => DrawerWidgetState();
}

class DrawerWidgetState extends State<DrawerWidget> {
  PackageInfo? _packageInfo;
  @override
  void initState() {
    _loadInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          ListTile(
            title: const Text('Usuários'),
            onTap: () async {
              await Navigator.pushNamed(
                context,
                AdminUsersPage.routeName,
              );
            },
          ),
          ListTile(
            title: const Text('Saques'),
            onTap: () async {
              await Navigator.pushNamed(
                context,
                AdminWithdrawPage.routeName,
              );
            },
          ),
          ListTile(
            title: const Text('Depósitos'),
            onTap: () async {
              await Navigator.pushNamed(
                context,
                AdminDepositPage.routeName,
              );
            },
          ),
          const Spacer(),
          ListTile(
            title: Text('Sair (${_packageInfo?.version ?? ''})'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  void _logout() {
    var authRepository = AuthRepository();
    authRepository.logout();
    // if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, LoginPage.routeName);
  }

  void _loadInfo() async {
    var packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      _packageInfo = packageInfo;
    });
  }
}
