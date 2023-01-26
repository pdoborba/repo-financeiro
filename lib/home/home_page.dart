// ignore_for_file: avoid_catches_without_on_clauses

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lpcapital/balance/balance_page.dart';
import 'package:lpcapital/common/colors.dart';
import 'package:lpcapital/common/widgets/app_bar_widget.dart';
import 'package:lpcapital/deposit/deposit_page.dart';
import 'package:lpcapital/history/history_page.dart';
import 'package:lpcapital/shop/shop_page.dart';
import 'package:lpcapital/withdraw/withdraw_page.dart';

import '../balance/balance_all_widget.dart';
import '../balance/balance_widget.dart';
import '../common/widgets/drawer.dart';

///HomePage
class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showBalance = true;
  int _selectedIndex = 0;

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
      endDrawer: DrawerWidget(
        callback: (DrawerItens item) {},
      ),
      appBar: AppBarWidget(
        hasBack: false,
        hasDrawer: true,
        hasClose: false,
        bgColor: AppColors.PRIMARY_COLOR,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image(
              image: AssetImage('assets/menu_home.png'),
              width: 15,
              height: 15,
            ),
            label: 'Início',
            backgroundColor: AppColors.PRIMARY_COLOR,
          ),
          BottomNavigationBarItem(
            icon: Image(
              image: AssetImage('assets/menu_market.png'),
              width: 15,
              height: 15,
            ),
            label: 'Mercado',
            backgroundColor: AppColors.PRIMARY_COLOR,
          ),
          BottomNavigationBarItem(
            icon: Image(
              image: AssetImage('assets/menu_lpinvest.png'),
              width: 15,
              height: 15,
            ),
            label: 'LP Invest',
            backgroundColor: AppColors.PRIMARY_COLOR,
          ),
          BottomNavigationBarItem(
            icon: Image(
              image: AssetImage('assets/menu_wallet.png'),
              width: 15,
              height: 15,
            ),
            label: 'Carteira',
            backgroundColor: AppColors.PRIMARY_COLOR,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
      extendBodyBehindAppBar: false,
      body: _buildHomeWidget(),
    );
  }

  Widget _buildHomeWidget() {
    return Column(
      children: [
        _buildHeaderWidget(),
        const SizedBox(
          height: 32,
        ),
        _buildBalanceWidget(),
        const SizedBox(
          height: 32,
        ),
        _buildBalanceActionsWidget(),
        // const SizedBox(
        //   height: 32,
        // ),
        // _buildCoinsWidget(),
      ],
    );
  }

  Widget _buildHeaderWidget() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    return Container(
        color: AppColors.PRIMARY_COLOR,
        child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Olá, ${auth.currentUser?.displayName}',
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
                IconButton(
                  onPressed: _toggleBalance,
                  icon: _showBalance
                      ? const Image(
                          image: AssetImage('assets/eye_on.png'),
                          color: Colors.white,
                          width: 24,
                          height: 24,
                        )
                      : const Image(
                          image: AssetImage('assets/eye_off.png'),
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                  color: Colors.white,
                )
              ],
            )));
  }

  Widget _buildBalanceWidget() {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        'Meu patrimônio',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      )
                    ]),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  _showBalance
                      ? const BalanceWidget(
                          fontSize: 28,
                        )
                      : const Text(
                          'R\$ ••••',
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                ]),
              ],
            ),
            IconButton(
                onPressed: _goToBalance,
                icon: const Icon(Icons.arrow_forward_ios))
          ],
        ));
  }

  Widget _buildBalanceActionsWidget() {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Row(
          children: [
            _buildBalanceActionItemWidget(
                'Depositar', 'assets/ic_deposit.png', _goToDeposit),
            const SizedBox(
              width: 16,
            ),
            _buildBalanceActionItemWidget(
                'Sacar', 'assets/ic_withdraw.png', _goToWithdraw),
            const SizedBox(
              width: 16,
            ),
            _buildBalanceActionItemWidget(
                'Locação', 'assets/ic_lend.png', _goToLend)
          ],
        ));
  }

  Widget _buildBalanceActionItemWidget(
      String text, String icon, Function() callback) {
    return GestureDetector(
        onTap: callback,
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 80,
              width: 80,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xff0078B7).withOpacity(0.1)),
              child: Image(
                width: 30,
                height: 30,
                image: AssetImage(icon),
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(text)
          ],
        ));
  }

  Widget _buildCoinsWidget() {
    return const Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: BalanceAllWidget());
  }

  void _toggleBalance() {
    setState(() {
      _showBalance = !_showBalance;
    });
  }

  void _goToHistory() async {
    await Navigator.pushNamed(
      context,
      HistoryPage.routeName,
    );
  }

  void _goToBalance() async {
    await Navigator.pushNamed(
      context,
      BalancePage.routeName,
    );
  }

  void _goToWithdraw() async {
    await Navigator.pushNamed(
      context,
      WithdrawPage.routeName,
    );
  }

    void _goToShop() async {
    await Navigator.pushNamed(
      context,
      ShopPage.routeName,
    );
  }

  void _goToDeposit() async {
    await Navigator.pushNamed(
      context,
      DepositPage.routeName,
    );
  }

  void _goToLend() async {}

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
      _goToShop();
        break;
      case 2:
        break;
      case 3:
        _goToBalance();
        break;
    }
  }
}
