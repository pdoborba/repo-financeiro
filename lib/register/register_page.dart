import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lpcapital/common/styles/styles.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/widgets/app_bar_widget.dart';
import '../common/widgets/main_button.dart';

class RegisterPage extends StatefulWidget {
  static const routeName = '/register';

  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

// ignore: prefer_mixin
class _RegisterPageState extends State<RegisterPage> with RouteAware {
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWeb => kIsWeb;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildRegisterWidget();
  }

  /// Builds the register widget that controls Firebase register state
  Widget buildRegisterWidget() {
    return Scaffold(
      appBar: AppBarWidget(
        hasClose: false,
        bgColor: Colors.transparent,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: buildMainWidget(),
      ),
    );
  }

  Widget buildMainWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registrar-se',
          style: Styles.titleStyle,
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          'Para cadastrar-se no aplicativo LPCapitals, favor entrar em contato com o e-mail lpcapital@gmail.com',
          style: Styles.bodyStyle,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          'Após isso, você receberá um retorno e um e-mail para definição de acesso a sua conta',
          style: Styles.bodyStyle,
        ),
        const Spacer(),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          MainButton(message: 'enviar email', callback: _sendEmail)
        ])
      ],
    );
  }

  void _sendEmail() {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'mpopolin@gmail.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Acesso ao aplicativo',
        'body': 'Olá! Gostaria de ter acesso ao aplicativo LPCapitals'
      }),
    );

    launchUrl(emailLaunchUri);
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
