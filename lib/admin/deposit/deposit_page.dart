import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../common/errors.dart';
import '../../deposit/deposit.dart';
import '../../deposit/deposit_bloc.dart';
import '../../deposit/deposit_event.dart';
import '../../deposit/deposit_state.dart';
import '../common/drawer_widget.dart';

///HomePage
class AdminDepositPage extends StatefulWidget {
  static const routeName = '/admin/deposits';

  const AdminDepositPage({Key? key}) : super(key: key);
  @override
  _AdminDepositPageState createState() => _AdminDepositPageState();
}

class _AdminDepositPageState extends State<AdminDepositPage> {
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
    Provider.of<DepositBloc>(context, listen: false).add(DepositLoad());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LPCapital - Depósitos')),
      drawer: const DrawerWidget(),
      body:
          Padding(padding: const EdgeInsets.all(16), child: _buildBlocWidget()),
    );
  }

  Widget _buildBlocWidget() {
    return BlocConsumer<DepositBloc, DepositState>(
      builder: (context, state) {
        if (state is DepositLoadInProgress) {
          return _buildLoadingWidget();
        } else if (state is DepositLoadSuccess) {
          return _buildDepositTable(state.deposits);
        } else {
          return _buildDepositTable([]);
        }
      },
      listener: (context, state) async {
        if (state is DepositConfirmFailure) {
          Errors.showError('Falha ao confirmar depósito, tente novamente');
        } else if (state is DepositConfirmSuccess) {
          Errors.showSuccess('Depósito confirmado com sucesso');
        } else if (state is DepositCancelSuccess) {
          Errors.showSuccess('Depósito cancelado com sucesso');
        } else if (state is DepositCancelFailure) {
          Errors.showSuccess('Falha ao cancelar depósito, tente novamente');
        }
      },
    );
  }

  Widget _buildDepositTable(List<Deposit> deposits) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        dataRowHeight: 100,
        minWidth: 600,
        columns: const [
          DataColumn2(
            label: Text('ID'),
            size: ColumnSize.L,
          ),
          DataColumn(
            label: Text('Data'),
          ),
          DataColumn(
            label: Text('Moeda'),
          ),
          DataColumn(
            label: Text('Tipo'),
          ),
          DataColumn(
            label: Text('Nome'),
          ),
          DataColumn(
            label: Text('Valor'),
          ),
          DataColumn(
            label: Text('Deadline'),
          ),
          DataColumn(
            label: Text('Status'),
          ),
        ],
        rows: deposits
            .map((e) => DataRow(cells: [
                  DataCell(Text(e.id)),
                  DataCell(Text(DateFormat('dd/MM/yy HH:mm')
                      .format(DateTime.parse(e.createdAt).toLocal()))),
                  DataCell(Text(e.asset)),
                  DataCell(Text(e.type)),
                  DataCell(Text(e.user?.name ?? '')),
                  DataCell(Text(formatCurrency.format(e.amount))),
                  DataCell(CountdownTimer(
                    endWidget: const Text('Expirado'),
                    endTime:
                        (DateTime.parse(e.createdAt).millisecondsSinceEpoch +
                            (24 * 60 * 60 * 1000)),
                  )),
                  DataCell(Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DepositStatus
                          .values[int.parse(e.status.toString())].name),
                      const SizedBox(
                        height: 8,
                      ),
                      e.status == DepositStatus.REQUESTED.index
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

  void _confirm(Deposit deposit) {
    Provider.of<DepositBloc>(context, listen: false)
        .add(DepositConfirm(deposit.id));
  }

  void _cancel(Deposit deposit) {
    Provider.of<DepositBloc>(context, listen: false)
        .add(DepositCancel(deposit.id));
  }
}
