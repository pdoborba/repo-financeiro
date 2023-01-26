// ignore_for_file: avoid_catches_without_on_clauses

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lpcapital/admin/user/user.dart';
import 'package:lpcapital/admin/user/user_arguments.dart';
import 'package:lpcapital/auth/auth_bloc.dart';
import 'package:lpcapital/common/widgets/main_button.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_event.dart';
import '../../auth/auth_state.dart';
import '../../common/errors.dart';
import '../../common/widgets/loading_widget.dart';

///HomePage
class AdminAddUserPage extends StatefulWidget {
  static const routeName = '/admin/user/add';

  const AdminAddUserPage({Key? key}) : super(key: key);
  @override
  _AdminAddUserPageState createState() => _AdminAddUserPageState();
}

class _AdminAddUserPageState extends State<AdminAddUserPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _name = TextEditingController();

  final GlobalKey<FormState> _formDocumentKey = GlobalKey<FormState>();

  final MaskTextInputFormatter _phoneFormatter = MaskTextInputFormatter(
      mask: '+## (##) ##### - ####', filter: {'#': RegExp(r'[0-9]')});
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
    var user = _getUser();
    if (user != null) {
      _email.text = user.email;
      _phone.text = _phoneFormatter.maskText(user.phone);
      _name.text = user.name;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var user = _getUser();
    return Scaffold(
      appBar: AppBar(
        title: Text(user != null
            ? 'LPCapital - Editar Usuário'
            : 'LPCapital - Adicionar Usuário'),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16), child: _buildEmailMainWidget()),
    );
  }

  Widget _buildEmailMainWidget() {
    return BlocConsumer<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoadInProgress) {
          return LoadingWidget();
        } else {
          return _buildRegisterWidget();
        }
      },
      listener: (context, state) async {
        var user = _getUser();
        if (state is AuthLoadSuccess) {
          Errors.showSuccess(user == null
              ? 'Usuário criado com sucesso'
              : 'Usuário editado com sucesso');
          Navigator.of(context).pop(true);
        } else if (state is AuthLoadFailure) {
          Errors.showError(user == null
              ? 'Falha ao criar usuário'
              : 'Falha ao editar usuário');
        }
      },
    );
  }

  Widget _buildRegisterWidget() {
    var user = _getUser();
    return Form(
      key: _formDocumentKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextFormField(
            decoration: const InputDecoration(
                labelText: 'Email', hintText: 'maria.marcele@email.com'),
            textInputAction: TextInputAction.next,
            controller: _email,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Por favor digite o email';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 16,
          ),
          TextFormField(
            decoration: const InputDecoration(
                labelText: 'Nome completo', hintText: 'Maria Marcele'),
            textInputAction: TextInputAction.next,
            controller: _name,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Por favor digite o nome';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 16,
          ),
          TextFormField(
            decoration: const InputDecoration(
                labelText: 'Celular', hintText: '+55 (19) 99999-9999'),
            textInputAction: TextInputAction.next,
            controller: _phone,
            inputFormatters: [_phoneFormatter],
            validator: (value) {
              if (value!.isEmpty) {
                return 'Por favor digite o celular';
              }
              if (_phoneFormatter.getUnmaskedText().isNotEmpty &&
                  !_phoneFormatter.isFill()) {
                return 'Por favor digite o número do celular no formato indicado';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 16,
          ),
          MainButton(
              message: user == null ? 'Cadastrar' : 'Editar',
              callback: _registerUser)
        ],
      ),
    );
  }

  void _registerUser() {
    if (_formDocumentKey.currentState!.validate()) {
      var user = _getUser();
      if (user != null) {
        Provider.of<AuthBloc>(context, listen: false).add(UpdateUser(
            user.id,
            _name.text,
            _email.text,
            '+${_phoneFormatter.unmaskText(_phone.text)})'));
      } else {
        Provider.of<AuthBloc>(context, listen: false).add(RegisterUser(
            _name.text,
            _email.text,
            '+${_phoneFormatter.unmaskText(_phone.text)})'));
      }
    }
  }

  User? _getUser() {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is UserArguments) {
      return args.user;
    }
    return null;
  }
}
