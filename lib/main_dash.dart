import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lpcapital/admin/deposit/deposit_page.dart';
import 'package:lpcapital/admin/user/repository/user_repository.dart';
import 'package:lpcapital/admin/user/user_add_page.dart';
import 'package:lpcapital/admin/user/user_bloc.dart';
import 'package:lpcapital/admin/withdraw/withdraw_page.dart';
import 'package:lpcapital/deposit/repository/deposit_repository.dart';
import 'package:lpcapital/firebase_options.dart';
import 'package:lpcapital/shop/shop_page.dart';
import 'package:lpcapital/withdraw/repository/withdraw_repository.dart';
import 'package:lpcapital/withdraw/withdraw_bloc.dart';
import 'admin/user/users_page.dart';
import 'auth/auth_bloc.dart';
import 'auth/auth_repository.dart';
import 'deposit/deposit_bloc.dart';
import 'admin/home/home_page.dart';
import 'login/login_page.dart';
import 'storage/database/database_helper.dart';

void main() async {
  await DatabaseHelper.instance.database;
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kIsWeb) {
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var color = {
      50: const Color.fromRGBO(49, 176, 186, .1),
      100: const Color.fromRGBO(49, 176, 186, .2),
      200: const Color.fromRGBO(49, 176, 186, .3),
      300: const Color.fromRGBO(49, 176, 186, .4),
      400: const Color.fromRGBO(49, 176, 186, .5),
      500: const Color.fromRGBO(49, 176, 186, .6),
      600: const Color.fromRGBO(49, 176, 186, .7),
      700: const Color.fromRGBO(49, 176, 186, .8),
      800: const Color.fromRGBO(49, 176, 186, .9),
      900: const Color.fromRGBO(49, 176, 186, 1),
    };

    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    FirebaseAnalyticsObserver observer =
        FirebaseAnalyticsObserver(analytics: analytics);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [],
      navigatorObservers: [observer],
      title: 'LPCapital',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF31B0BA, color),
      ),
      initialRoute: LoginPage.routeName,
      routes: {
        LoginPage.routeName: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>(
                  create: (context) => AuthBloc(
                    authRepository: AuthRepository(),
                  ),
                ),
              ],
              child: const LoginPage(),
            ),

        // Admin
        AdminHomePage.routeName: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>(
                  create: (context) => AuthBloc(
                    authRepository: AuthRepository(),
                  ),
                ),
              ],
              child: const AdminHomePage(),
            ),
        AdminUsersPage.routeName: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>(
                  create: (context) => AuthBloc(
                    authRepository: AuthRepository(),
                  ),
                ),
                BlocProvider<UserBloc>(
                  create: (context) => UserBloc(repository: UserRepository()),
                ),
              ],
              child: const AdminUsersPage(),
            ),
        AdminAddUserPage.routeName: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>(
                  create: (context) => AuthBloc(
                    authRepository: AuthRepository(),
                  ),
                ),
                BlocProvider<UserBloc>(
                  create: (context) => UserBloc(repository: UserRepository()),
                ),
              ],
              child: const AdminAddUserPage(),
            ),
        AdminWithdrawPage.routeName: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>(
                  create: (context) => AuthBloc(
                    authRepository: AuthRepository(),
                  ),
                ),
                BlocProvider<WithdrawBloc>(
                  create: (context) =>
                      WithdrawBloc(withdrawRepository: WithdrawRepository()),
                ),
              ],
              child: const AdminWithdrawPage(),
            ),
        AdminDepositPage.routeName: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>(
                  create: (context) => AuthBloc(
                    authRepository: AuthRepository(),
                  ),
                ),
                BlocProvider<DepositBloc>(
                  create: (context) =>
                      DepositBloc(depositRepository: DepositRepository()),
                ),
              ],
              child: const AdminDepositPage(),
            ),
        ShopPage.routeName: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>(
                  create: (context) => AuthBloc(
                    authRepository: AuthRepository(),
                  ),
                ),
                BlocProvider<WithdrawBloc>(
                  create: (context) =>
                      WithdrawBloc(withdrawRepository: WithdrawRepository()),
                ),
              ],
              child: const ShopPage(),
            ),
      },
    );
  }
}
