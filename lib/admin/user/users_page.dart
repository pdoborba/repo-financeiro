// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:math';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lpcapital/admin/user/user_bloc.dart';
import 'package:lpcapital/admin/user/user_state.dart';
import 'package:lpcapital/common/widgets/main_button.dart';
import 'package:provider/provider.dart';

import '../common/drawer_widget.dart';
import 'user.dart';
import 'user_add_page.dart';
import 'user_arguments.dart';
import 'user_event.dart';

///HomePage
class AdminUsersPage extends StatefulWidget {
  static const routeName = '/admin/users';

  const AdminUsersPage({Key? key}) : super(key: key);
  @override
  _AdminUsersPageState createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
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
    Provider.of<UserBloc>(context, listen: false).add(const UserLoad());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LPCapital - Usuários')),
      drawer: const DrawerWidget(),
      body:
          Padding(padding: const EdgeInsets.all(16), child: _buildBlocWidget()),
    );
  }

  Widget _buildBlocWidget() {
    return BlocConsumer<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoadInProgress) {
          return _buildLoadingWidget();
        } else if (state is UserLoadSuccess) {
          return _buildUserTable(state.users);
        } else {
          return _buildUserTable([]);
        }
      },
      listener: (context, state) async {},
    );
  }

  Widget _buildUserTable(List<User> users) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          MainButton(message: 'adicionar usuário', callback: _addUser)
        ]),
        const SizedBox(
          height: 16,
        ),
        Expanded(
            child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                columns: const [
                  DataColumn2(
                    label: Text('ID'),
                    size: ColumnSize.L,
                  ),
                  DataColumn(
                    label: Text('Nome'),
                  ),
                  DataColumn(
                    label: Text('Email'),
                  ),
                  DataColumn(
                    label: Text('Telefone'),
                  ),
                  DataColumn(
                    label: Text('Detalhes'),
                  ),
                ],
                rows: users
                    .map((e) => DataRow(cells: [
                          DataCell(Text(e.id)),
                          DataCell(Text(e.name)),
                          DataCell(Text(e.email)),
                          DataCell(Text(e.phone)),
                          DataCell(IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: (() => _editUser(e))))
                        ]))
                    .toList()))
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  void _addUser() async {
    var result = await Navigator.pushNamed(
      context,
      AdminAddUserPage.routeName,
    );

    if (result == true) {
      if (!mounted) return;
      Provider.of<UserBloc>(context, listen: false).add(const UserLoad());
    }
  }

  void _editUser(User user) async {
    var result = await Navigator.pushNamed(context, AdminAddUserPage.routeName,
        arguments: UserArguments(user));

    if (result == true) {
      if (!mounted) return;
      Provider.of<UserBloc>(context, listen: false).add(const UserLoad());
    }
  }
}
