import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../common/widgets/loading_widget.dart';
import 'balance.dart';
import 'balance_bloc.dart';
import 'balance_state.dart';

class BalanceWidget extends StatefulWidget {
  static const updateBalanceAction = 'balance_updated';
  final double? fontSize;

  const BalanceWidget({Key? key, this.fontSize}) : super(key: key);

  @override
  State<StatefulWidget> createState() => BalanceWidgetState();
}

class BalanceWidgetState extends State<BalanceWidget> {
  final Color mainColor = const Color(0xff31b0ba);
  late Timer _timer;
  List<Balance>? lastBalances;
  DateTime? lastBalanceTime;

  @override
  void initState() {
    _loadData();
    _timer =
        Timer.periodic(const Duration(hours: 1), (t) => setState(_loadData));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[buildBalanceWidget()],
    );
  }

  @override
  void dispose() async {
    _timer.cancel();
    super.dispose();
  }

  Widget buildBalanceWidget() {
    return BlocBuilder<BalanceBloc, BalanceState>(
      builder: (context, state) {
        if (state is BalanceLoadInProgress) {
          return _buildLoadingWidget();
        } else if (state is BalanceLoadFailure) {
          return _buildSuccessWidget();
        } else if (state is BalanceLoadSuccess) {
          lastBalances = state.balances;
          lastBalanceTime = DateTime.now();
          return _buildSuccessWidget();
        } else {
          return _buildLoadingWidget();
        }
      },
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

  Widget _buildSuccessWidget() {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    if (lastBalances != null && lastBalances!.isNotEmpty) {
      var text = '';
      num totalBrl = 0;
      for (var balance in lastBalances ?? []) {
        totalBrl += balance.brlFree ?? 0;
      }
      text += formatCurrency.format(totalBrl);
      return buildText(text);
    } else {
      return buildText('falha ao buscar saldo');
    }
  }

  Widget buildText(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
              fontSize: widget.fontSize,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _loadData() {
    Provider.of<BalanceBloc>(context, listen: false)
        .add(BalanceEvents.BalanceInitial);
    Provider.of<BalanceBloc>(context, listen: false)
        .add(BalanceEvents.BalanceLoad);
  }
}
