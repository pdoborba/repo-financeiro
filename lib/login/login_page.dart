import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../admin/home/home_page.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_event.dart';
import '../auth/auth_state.dart';
import '../common/colors.dart';
import '../common/errors.dart';
import '../common/views/keyboard_visibility.dart';
import '../common/widgets/loading_widget.dart';
import '../common/widgets/main_button.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/loginPage';

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

// ignore: prefer_mixin
class _LoginPageState extends State<LoginPage> with RouteAware {
  bool hasShownCreatedDialog = false;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  final MaskTextInputFormatter _phoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####', filter: {'#': RegExp(r'[0-9]')});
  final TextEditingController _phoneController = TextEditingController();
  String? verificationId;

  final PageController _pageController = PageController(
    initialPage: 0,
  );

  bool _showRegisterText = true;
  String? _pin;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWeb => kIsWeb;

  @override
  void initState() {
    Provider.of<AuthBloc>(context, listen: false).add(CheckLogin());
    _phoneController.addListener(_validatePhone);
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildLoginWidget();
  }

  /// Builds the login widget that controls Firebase login state
  Widget buildLoginWidget() {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          floatingActionButton: _buildFab(),
          body: _buildMainWidget(),
        ));
  }

  Widget _buildMainWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/login_top.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: Image(
                  image: AssetImage('assets/ic_logo_2.png'),
                  width: 231,
                  height: 100,
                ),
              ),
            )),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              TabBar(
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3.0),
                ),
                tabs: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: const Text(
                      'email',
                      style: TextStyle(
                          color: AppColors.PRIMARY_COLOR, fontSize: 20),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: const Text(
                      'celular',
                      style: TextStyle(
                          color: AppColors.PRIMARY_COLOR, fontSize: 20),
                    ),
                  ),
                ],
              ),
              Expanded(
                  child: TabBarView(
                children: [
                  _buildEmailMainWidget(),
                  _buildPhoneMainWidget(),
                ],
              )),
            ],
          ),
        )

        // const SizedBox(
        //   height: 32,
        // ),

        // Expanded(
        //     flex: 5,
        //     child: TabBarView(
        //       children: [
        //         _buildEmailMainWidget(),
        //         _buildPhoneMainWidget(),
        //       ],
        //     )),
        // SizedBox(
        //   height: 256,
        // ),
      ],
    );
  }

  Widget _buildEmailMainWidget() {
    return BlocConsumer<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoadInProgress) {
          return LoadingWidget();
        } else {
          return _buildAuthForm();
        }
      },
      listener: (context, state) async {
        if (state is AuthLoadSuccess) {
          await Navigator.pushReplacementNamed(
            context,
            _email.text == 'admin@lpcapital.org.br'
                ? AdminHomePage.routeName
                : HomePage.routeName,
          );
        } else if (state is AuthLoadFailure) {
          Provider.of<AuthBloc>(context, listen: false).add(Logout());
          Errors.showError('Falha ao realizar login');
        }
      },
    );
  }

  Widget _buildPhoneMainWidget() {
    return BlocConsumer<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSmsSent) {
          return _buildAuthSmsForm();
        } else if (state is AuthLoadInProgress) {
          return LoadingWidget();
        } else {
          return _buildPhoneForm();
        }
      },
      listener: (context, state) async {
        if (state is AuthLoadSuccess) {
          await Navigator.pushReplacementNamed(
            context,
            HomePage.routeName,
          );
        } else if (state is AuthLoadFailure) {
          Provider.of<AuthBloc>(context, listen: false).add(Logout());
          Errors.showError('Falha ao realizar login');
        } else if (state is AuthSmsSent) {
          verificationId = state.verificationId;
        }
      },
    );
  }

  /// Builds the widget that shows the login options
  Widget _buildAuthForm() {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <
            Widget>[
          // const Expanded(flex: 1, child: SizedBox()),
          // isIOS
          //     ? _buildLoginButton('assets/apple.png', 'entrar com Apple',
          //         _handleAppleSignIn)
          //     : const SizedBox(),
          // SizedBox(
          //   height: isIOS ? 16 : 0,
          // ),
          _buildLoginButton(
              'assets/google.png', 'entrar com Google', _handleGoogleSignIn),
          // ),
          // FacebookAuthButton(
          //     style: AuthButtonStyle(width: 250),
          //     onPressed: _handleFacebookSignIn,
          //     text: 'Entrar com Facebook'),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Expanded(
                child: Divider(),
              ),
              SizedBox(
                width: 16,
              ),
              Text(
                'ou',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: Divider(),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          _showRegisterText ? _buildEmailForm() : _buildRegisterForm(),
          const SizedBox(
            height: 16,
          ),
          _showRegisterText
              ? MainButton(message: 'entrar', callback: _loginUserAndPassword)
              : MainButton(
                  message: 'Enviar e-mail',
                  callback: _sendRegisterEmail,
                ),
          const Spacer(),
          Text(
            _showRegisterText ? 'Não possui conta?' : 'Já possui uma conta',
            style: const TextStyle(fontSize: 12),
          ),
          InkWell(
            onTap: _register,
            child: Text(
              _showRegisterText ? 'Cadastre-se' : 'Fazer Login',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
            ),
          ),
        ]));
  }

  Widget _buildEmailForm() {
    return Column(children: [
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'E-mail',
          hintText: 'E-mail',
        ),
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
          labelText: 'Senha',
          hintText: 'Senha',
        ),
        obscureText: true,
        textInputAction: TextInputAction.done,
        controller: _password,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Por favor digite a senha';
          }
          return null;
        },
      ),
      const SizedBox(
        height: 4,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: _forgotPassword,
            child: const Text(
              'Esqueci minha senha',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildLoginButton(String icon, String title, VoidCallback onTap) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(36)),
            ),
            child: Row(children: [
              Expanded(
                  flex: 1,
                  child: Image.asset(
                    icon,
                    width: 25,
                    height: 25,
                  )),
              Expanded(flex: 2, child: Text(title))
            ])));
  }

  Widget _buildFab() {
    return KeyboardVisibilityBuilder(
      builder: (context, child, isKeyboardVisible) {
        return Visibility(
          visible: isKeyboardVisible,
          child: child,
        );
      },
      child: FloatingActionButton(
        backgroundColor: AppColors.PRIMARY_COLOR,
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: const Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAuthSmsForm() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      // Note: Styles for TextSpans must be explicitly defined.
                      // Child text spans will inherit styles from parent
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Digite o código que você recebeu por SMS'),
                      ],
                    ),
                  ),
                ],
              )),
          Container(
              padding: const EdgeInsets.all(24),
              child: _buildSmsCodeInputField()),
          const SizedBox(height: 32),
          const Text(
            'Não recebeu o código?',
            style: TextStyle(fontSize: 12),
          ),
          InkWell(
            onTap: _resend,
            child: const Text(
              'Reenviar',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
            ),
          ),
        ]);
  }

  Widget _buildPhoneForm() {
    return Padding(
        padding: const EdgeInsets.all(24),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          _showRegisterText ? _buildPhoneInputField() : _buildRegisterForm(),
          const SizedBox(height: 16),
          _showRegisterText
              ? MainButton(
                  message: 'entrar',
                  callback: _validatePhone,
                )
              : MainButton(
                  message: 'Enviar e-mail',
                  callback: _sendRegisterEmail,
                ),
          const SizedBox(height: 32),
          const Text(
            'Não possui conta?',
            style: TextStyle(fontSize: 12),
          ),
          InkWell(
            onTap: _register,
            child: Text(
              _showRegisterText ? 'Cadastre-se' : 'Fazer Login',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
            ),
          ),
        ]));
  }

  Widget _buildRegisterForm() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Cadastre-se',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            'Para cadastrar-se no aplicativo LPCapital, entre em contato através do e-mail Ipcapital@gmail.com.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            'Você receberá um retorno com a definição de acesso a sua conta.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
          )
        ]);
  }

  Widget _buildPhoneInputField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: TextField(
            inputFormatters: [_phoneFormatter],
            keyboardType: TextInputType.phone,
            controller: _phoneController,
            style: const TextStyle(fontSize: 20),
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: '(19) 99999-9999',
              errorText: _phoneController.text.length == 15 ||
                      _phoneController.text.isEmpty
                  ? null
                  : 'Preencha o telefone corretamente',
              labelText: 'Número do celular',
              labelStyle: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmsCodeInputField() {
    return Column(children: <Widget>[
      PinInputTextField(
        pinLength: 6,
        decoration: const BoxLooseDecoration(
            strokeColorBuilder: FixedColorBuilder(AppColors.PRIMARY_COLOR)),

        onChanged: (pin) {
          if (pin.length == 6) {
            _pin = pin;
            Provider.of<AuthBloc>(context, listen: false)
                .add(ValidateSms(sms: pin, verificationId: verificationId));
          }
        },
        onSubmit: (pin) {}, // end onSubmit
      ),
    ]);
  }

  void _showSnackBar(String error, context, Color color) {
    final snackBar = SnackBar(
      content: Text(error),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _forgotPassword() async {
    if (_email.text.isEmpty) {
      _showSnackBar(
          'Preencha o campo email'
          '',
          context,
          Colors.red);
    } else {
      Provider.of<AuthBloc>(context, listen: false)
          .add(ForgotPassword(_email.text.toLowerCase().trim()));
      _showSnackBar('Verifique o seu email para instruções de troca de senha',
          context, Colors.green);
    }
  }

  void _loginUserAndPassword() async {
    if (_email.text.isEmpty) {
      _showSnackBar(
          'Preencha o campo email e senha'
          '',
          context,
          Colors.red);
    } else {
      Provider.of<AuthBloc>(context, listen: false).add(
          EmailPasswordLogin(_email.text.toLowerCase().trim(), _password.text));
    }
  }

  void _handleGoogleSignIn() async {
    Provider.of<AuthBloc>(context, listen: false).add(GoogleLogin());
  }

  void _validatePhone() {
    if (_phoneController.text.length == 15) {
      Provider.of<AuthBloc>(context, listen: false)
          .add(SendSms(phone: _phoneController.text));
      _phoneController.clear();
    }
  }

  void _register() async {
    setState(() {
      _showRegisterText = !_showRegisterText;
    });
    // await Navigator.pushNamed(
    //   context,
    //   RegisterPage.routeName,
    // );
  }

  void _resend() {
    Provider.of<AuthBloc>(context, listen: false)
        .add(ValidateSms(sms: _pin ?? '', verificationId: verificationId));
  }

  void _sendRegisterEmail() {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'admin@lpcapital.org',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Acesso ao aplicativo',
        'body': 'Olá! Gostaria de ter acesso ao aplicativo LPCapital'
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
