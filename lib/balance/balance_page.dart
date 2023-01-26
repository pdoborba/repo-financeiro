import 'package:flutter/material.dart';
import 'package:lpcapital/common/colors.dart';
import 'package:lpcapital/common/widgets/main_button.dart';
import 'package:provider/provider.dart';

import '../common/widgets/app_bar_widget.dart';
import '../history/history_page.dart';
import 'balance_all_widget.dart';
import 'balance_bloc.dart';
import 'balance_widget.dart';

class BalancePage extends StatefulWidget {
  static const routeName = '/balance';
  const BalancePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => BalancePageState();
}

class BalancePageState extends State<BalancePage> {
  final Color mainColor = const Color(0xff31b0ba);

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        hasBack: false,
        hasIcon: false,
        hasClose: true,
        bgColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: false,
      body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: _buildMainWidget()),
    );
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Widget _buildMainWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderWidget(),
        const SizedBox(
          height: 24,
        ),
        const Text(
          'Minha Carteira',
          style: TextStyle(
              fontSize: 28,
              color: AppColors.PRIMARY_COLOR,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(
          height: 16,
        ),
        _buildBalanceResumeWidget(),
        const SizedBox(
          height: 32,
        ),
        Expanded(
          child: Container(
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.all(Radius.circular(16))),
            child: const SingleChildScrollView(child: BalanceAllWidget()),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        MainButton(message: 'Consultar Extrato', callback: _goToHistory)
      ],
    );
  }

  Widget _buildBalanceResumeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
              Text(
                'Meu patrimônio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              )
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
              BalanceWidget(
                fontSize: 28,
              )
            ]),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: const [
        Image(
          image: AssetImage('assets/menu_wallet.png'),
          color: Colors.grey,
          width: 44,
          height: 40,
        )
      ],
    );
  }

  void _loadData() {
    Provider.of<BalanceBloc>(context, listen: false)
        .add(BalanceEvents.BalanceInitial);
    Provider.of<BalanceBloc>(context, listen: false)
        .add(BalanceEvents.BalanceLoad);
  }

  void _goToHistory() async {
    await Navigator.pushNamed(
      context,
      HistoryPage.routeName,
    );
  }
}
