import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../coin/coin.dart';
import '../common/widgets/loading_widget.dart';
import 'balance.dart';
import 'balance_bloc.dart';
import 'balance_state.dart';

class BalanceAllWidget extends StatefulWidget {
  final double? fontSize;

  const BalanceAllWidget({Key? key, this.fontSize}) : super(key: key);

  @override
  State<StatefulWidget> createState() => BalanceAllWidgetState();
}

class BalanceAllWidgetState extends State<BalanceAllWidget> {
  final Color mainColor = const Color(0xff31b0ba);
  List<Balance>? lastBalances;
  DateTime? lastBalanceTime;
  final _formatCurrency = NumberFormat.simpleCurrency(locale: 'pt_BR');

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBalanceWidget();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Widget _buildBalanceWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Text(
              'Ativos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            )
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        BlocBuilder<BalanceBloc, BalanceState>(
          builder: (context, state) {
            if (state is BalanceLoadInProgress) {
              return _buildLoadingWidget();
            } else if (state is BalanceLoadFailure) {
              return _buildSuccessWidget(lastBalances ?? []);
            } else if (state is BalanceLoadSuccess) {
              lastBalances = state.balances;
              lastBalanceTime = DateTime.now();
              return _buildSuccessWidget(lastBalances ?? []);
            } else {
              return _buildLoadingWidget();
            }
          },
        )
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: 15,
      height: 15,
      alignment: Alignment.centerRight,
      child: LoadingWidget(),
    );
  }

  Widget _buildSuccessWidget(List<Balance> balances) {
    if (balances.isEmpty) {
      return const Text('Você ainda não tem ativos para exibir');
    }
    return Column(
      children: [...balances.map((e) => _buildCoinItemWidget(e))],
    );
  }

  Widget _buildCoinItemWidget(Balance balance) {
    Coin? coin = Coin.values.firstWhereOrNull(
        (element) => element.shortName == balance.asset.toUpperCase());

    if (coin == null) {
      return const SizedBox();
    }

    return SizedBox(
        height: 70,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Image(
                  height: 48,
                  width: 48,
                  image: AssetImage(coin.asset),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      balance.asset,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      coin.name,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        balance.free.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        _formatCurrency.format(balance.asset == 'BRL'
                            ? balance.free
                            : balance.brlFree),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ))
            ],
          ),
          const Divider(),
        ]));
    // return Padding(
    //     padding: const EdgeInsets.all(4),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         // Checkbox(
    //         //   value: false,
    //         //   onChanged: (bool? newValue) {},
    //         // ),
    //         Text(title),
    //         Text(description)
    //       ],
    //     ));
  }

  void _loadData() {
    Provider.of<BalanceBloc>(context, listen: false)
        .add(BalanceEvents.BalanceInitial);
    Provider.of<BalanceBloc>(context, listen: false)
        .add(BalanceEvents.BalanceLoad);
  }
}
