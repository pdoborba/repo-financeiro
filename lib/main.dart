import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lpcapital/account/account_bloc.dart';
import 'package:lpcapital/account/repository/account_repository.dart';
import 'package:lpcapital/balance/balance_bloc.dart';
import 'package:lpcapital/balance/balance_page.dart';
import 'package:lpcapital/balance/repository/balance_repository.dart';
import 'package:lpcapital/coin/coin_bloc.dart';
import 'package:lpcapital/coin/repository/coin_repository.dart';
import 'package:lpcapital/deposit/repository/deposit_repository.dart';
import 'package:lpcapital/firebase_options.dart';
import 'package:lpcapital/history/history_bloc.dart';
import 'package:lpcapital/history/repository/history_repository.dart';
import 'package:lpcapital/register/register_page.dart';
import 'package:lpcapital/shop/shop_page.dart';
import 'package:lpcapital/withdraw/repository/withdraw_repository.dart';
import 'package:lpcapital/withdraw/withdraw_bloc.dart';
import 'package:lpcapital/withdraw/withdraw_page.dart';
import 'auth/auth_bloc.dart';
import 'auth/auth_repository.dart';
import 'deposit/deposit_bloc.dart';
import 'deposit/deposit_page.dart';
import 'history/history_page.dart';
import 'home/home_page.dart';
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
      // initialRoute: AdminHomePage.routeName,
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
        HomePage.routeName: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>(
                  create: (context) => AuthBloc(
                    authRepository: AuthRepository(),
                  ),
                ),
                BlocProvider<BalanceBloc>(
                  create: (context) => BalanceBloc(
                    balanceRepository: BalanceRepository(),
                  ),
                ),
              ],
              child: const HomePage(),
            ),
        HistoryPage.routeName: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<HistoryBloc>(
                  create: (context) => HistoryBloc(
                    historyRepository: HistoryRepository(),
                  ),
                ),
              ],
              child: const HistoryPage(),
            ),
        RegisterPage.routeName: (context) => const RegisterPage(),
        WithdrawPage.routeName: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<CoinBloc>(
                  create: (context) => CoinBloc(
                    coinRepository: CoinRepository(),
                  ),
                ),
                BlocProvider<WithdrawBloc>(
                  create: (context) => WithdrawBloc(
                    withdrawRepository: WithdrawRepository(),
                  ),
                ),
                BlocProvider<AccountBloc>(
                  create: (context) => AccountBloc(
                    accountRepository: AccountRepository(),
                  ),
                ),
                BlocProvider<AuthBloc>(
                  create: (context) => AuthBloc(
                    authRepository: AuthRepository(),
                  ),
                ),
                BlocProvider<BalanceBloc>(
                  create: (context) => BalanceBloc(
                    balanceRepository: BalanceRepository(),
                  ),
                ),
              ],
              child: const WithdrawPage(),
            ),
        DepositPage.routeName: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<DepositBloc>(
                  create: (context) => DepositBloc(
                    depositRepository: DepositRepository(),
                  ),
                ),
                BlocProvider<AccountBloc>(
                  create: (context) => AccountBloc(
                    accountRepository: AccountRepository(),
                  ),
                ),
                BlocProvider<AuthBloc>(
                  create: (context) => AuthBloc(
                    authRepository: AuthRepository(),
                  ),
                ),
                BlocProvider<BalanceBloc>(
                  create: (context) => BalanceBloc(
                    balanceRepository: BalanceRepository(),
                  ),
                ),
              ],
              child: const DepositPage(),
            ),
        BalancePage.routeName: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<BalanceBloc>(
                  create: (context) => BalanceBloc(
                    balanceRepository: BalanceRepository(),
                  ),
                ),
              ],
              child: const BalancePage(),
            ),
        ShopPage.routeName: (context) => MultiBlocProvider(
              providers: [
                   BlocProvider<CoinBloc>(
                  create: (context) => CoinBloc(
                    coinRepository: CoinRepository(),
                  ),
                ),
                BlocProvider<WithdrawBloc>(
                  create: (context) => WithdrawBloc(
                    withdrawRepository: WithdrawRepository(),
                  ),
                ),
                BlocProvider<AccountBloc>(
                  create: (context) => AccountBloc(
                    accountRepository: AccountRepository(),
                  ),
                ),
                BlocProvider<AuthBloc>(
                  create: (context) => AuthBloc(
                    authRepository: AuthRepository(),
                  ),
                ),
                BlocProvider<BalanceBloc>(
                  create: (context) => BalanceBloc(
                    balanceRepository: BalanceRepository(),
                  ),
                ),
              ],
              child: const ShopPage(),
            ),
      },
    );
  }
}
