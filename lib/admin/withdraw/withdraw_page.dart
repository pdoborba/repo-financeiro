import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../common/errors.dart';
import '../../withdraw/withdraw.dart';
import '../../withdraw/withdraw_bloc.dart';
import '../../withdraw/withdraw_event.dart';
import '../../withdraw/withdraw_state.dart';
import '../common/drawer_widget.dart';

///HomePage
class AdminWithdrawPage extends StatefulWidget {
  static const routeName = '/admin/withdraws';

  const AdminWithdrawPage({Key? key}) : super(key: key);
  @override
  _AdminWithdrawPageState createState() => _AdminWithdrawPageState();
}

class _AdminWithdrawPageState extends State<AdminWithdrawPage> {
  @override
  void initState() {
    initializeDateFormatting('pt_BR', null);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    Provider.of<WithdrawBloc>(context, listen: false).add(WithdrawLoad());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LPCapital - Saques')),
      drawer: const DrawerWidget(),
      body:
          Padding(padding: const EdgeInsets.all(16), child: _buildBlocWidget()),
    );
  }

  Widget _buildBlocWidget() {
    return BlocConsumer<WithdrawBloc, WithdrawState>(
      builder: (context, state) {
        if (state is WithdrawLoadInProgress) {
          return _buildLoadingWidget();
        } else if (state is WithdrawLoadSuccess) {
          return _buildWithdrawTable(state.withdraws);
        } else {
          return _buildWithdrawTable([]);
        }
      },
      listener: (context, state) async {
        if (state is WithdrawConfirmFailure) {
          Errors.showError('Falha ao realizar operação, tente novamente');
        } else if (state is WithdrawConfirmSuccess) {
          Errors.showSuccess('Operação realizada com sucesso');
        }
      },
    );
  }

  Widget _buildWithdrawTable(List<Withdraw> withdraws) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        dataRowHeight: 100,
        minWidth: 600,
        columns: const [
          DataColumn2(
            label: Text('ID'),
          ),
          DataColumn(
            label: Text('Data'),
          ),
          DataColumn(
            label: Text('Tipo Conta'),
          ),
          DataColumn(
            label: Text('Nome'),
          ),
          DataColumn(
            label: Text('Dados Bancários'),
          ),
          DataColumn(
            label: Text('Valor Bruto'),
          ),
          DataColumn(
            label: Text('Taxa'),
          ),
          DataColumn(
            label: Text('Valor Líquido'),
          ),
          DataColumn(
            label: Text('Deadline'),
          ),
          DataColumn(
            label: Text('Status'),
          ),
        ],
        rows: withdraws
            .map((e) => DataRow(cells: [
                  DataCell(Text(e.id)),
                  DataCell(Text(DateFormat('dd/MM/yy HH:mm')
                      .format(DateTime.parse(e.createdAt).toLocal()))),
                  DataCell(Text(e.account?.type ?? '')),
                  DataCell(Text(e.account?.user?.name ?? '')),
                  DataCell(Text(e.account?.toString() ?? '')),
                  DataCell(Text(formatCurrency.format(e.amount))),
                  DataCell(Text(formatCurrency.format(e.tax))),
                  DataCell(Text(formatCurrency.format(e.amount - e.tax))),
                  DataCell(CountdownTimer(
                      endWidget: const Text('Expirado'),
                      endTime:
                          (DateTime.parse(e.createdAt).millisecondsSinceEpoch +
                              (24 * 60 * 60 * 1000)))),
                  DataCell(Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(WithdrawStatus
                          .values[int.parse(e.status.toString())].name),
                      const SizedBox(
                        height: 8,
                      ),
                      e.status == WithdrawStatus.REQUESTED.index
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                  ElevatedButton(
                                      onPressed: () => _confirm(e),
                                      child: const Text('Confirmar')),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  ElevatedButton(
                                      onPressed: () => _cancel(e),
                                      child: const Text('Cancelar'))
                                ])
                          : const SizedBox.shrink()
                    ],
                  )),
                ]))
            .toList());
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  void _confirm(Withdraw item) {
    Provider.of<WithdrawBloc>(context, listen: false)
        .add(WithdrawConfirm(item.id));
  }

  void _cancel(Withdraw item) {
    Provider.of<WithdrawBloc>(context, listen: false)
        .add(WithdrawCancel(item.id));
  }
}
