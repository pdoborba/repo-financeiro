// ignore_for_file: avoid_catches_without_on_clauses

import 'package:flutter/material.dart';

import '../common/drawer_widget.dart';
import '../user/users_page.dart';

///HomePage
class AdminHomePage extends StatefulWidget {
  static const routeName = '/admin/home';

  const AdminHomePage({Key? key}) : super(key: key);
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LPCapital - Home')),
      drawer: const DrawerWidget(),
      body:
          Padding(padding: const EdgeInsets.all(16), child: _buildMainWidget()),
    );
  }

  Widget _buildMainWidget() {
    return const Center(
      child:
          Text('Favor utilizar o menú lateral para acessar as funcionalidades'),
    );
  }
}
