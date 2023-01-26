import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../common/colors.dart';
import '../common/widgets/app_bar_widget.dart';
import '../common/widgets/loading_widget.dart';
import 'history.dart';
import 'transfer.dart';
import 'history_bloc.dart';
import 'history_state.dart';

class HistoryPage extends StatefulWidget {
  static const routeName = '/history';
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  final Color mainColor = const Color(0xff31b0ba);

  @override
  void initState() {
    initializeDateFormatting('pt_BR', null);
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
          'Histórico Transações',
          style: TextStyle(
              fontSize: 28,
              color: AppColors.PRIMARY_COLOR,
              fontWeight: FontWeight.w700),
        ),
        // _buildFilterWidget(),
        const SizedBox(
          height: 16,
        ),
        Expanded(
            child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: const BorderRadius.all(Radius.circular(16))),
          child: _buildHistoryWidget(),
        )),
        const SizedBox(
          height: 16,
        ),
        _buildStatusWidget(),
      ],
    );
  }

  Widget _buildStatusWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
            onTap: _showStatusHelp,
            child: const Text(
              'Dúvidas com o status?',
              style: TextStyle(
                  fontSize: 10,
                  decoration: TextDecoration.underline,
                  color: AppColors.SECONDARY_COLOR),
            ))
      ],
    );
  }

  Widget _buildHeaderWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: const [
        Image(
          image: AssetImage('assets/menu_history.png'),
          color: Colors.grey,
          width: 44,
          height: 40,
        )
      ],
    );
  }

  Widget _buildHistoryWidget() {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoadInProgress) {
          return _buildLoadingWidget();
        } else if (state is HistoryLoadFailure) {
          return _buildSuccessWidget(null);
        } else if (state is HistoryLoadSuccess) {
          return _buildSuccessWidget(state.history);
        } else {
          return _buildLoadingWidget();
        }
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
        child: Container(
      width: 15,
      height: 15,
      alignment: Alignment.centerRight,
      child: LoadingWidget(),
    ));
  }

  Widget _buildSuccessWidget(History? history) {
    var items = <Transfer>[];
    if (history != null) {
      for (var element in history.withdraws) {
        items.add(Transfer(element, null));
      }
      for (var element in history.deposits) {
        items.add(Transfer(null, element));
      }
    }

    if (items.isEmpty) {
      return const Center(
          child: Text(
        'Não há movimentação na conta até o momento',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
      ));
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildHistoryItem(items[index]);
        },
      );
    }
  }

  Widget _buildHistoryItem(Transfer transfer) {
    return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                flex: 1,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Image(
                      width: 48,
                      height: 48,
                      image: AssetImage(transfer.isWithdraw() == true
                          ? 'assets/history_withdraw.png'
                          : 'assets/history_deposit.png'))
                ])),
            const SizedBox(
              width: 16,
            ),
            Expanded(
                flex: 5,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${transfer.isWithdraw() ? 'Saque' : 'Depósito'} ${transfer.getAsset()}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(transfer.getTo()),
                      _buildStatusItemWidget(transfer.getStatus())
                    ])),
            Expanded(
                flex: 2,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat.yMMMEd('pt-BR').format(
                          DateTime.parse(transfer.getTime()).toLocal())),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        transfer.getQty(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      )
                    ])),
          ],
        ));
  }

  Widget _buildStatusItemWidget(String status) {
    var transferStatus = TransferStatus.values.byName(status);
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
              color: transferStatus.color, shape: BoxShape.circle),
        ),
        const SizedBox(
          width: 8,
        ),
        Text(
          transferStatus.title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        )
      ],
    );
  }

  void _loadData() {
    Provider.of<HistoryBloc>(context, listen: false)
        .add(HistoryEvents.HistoryInitial);
    Provider.of<HistoryBloc>(context, listen: false)
        .add(HistoryEvents.HistoryLoad);
  }

  void _sendMailHelp() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'admin@lpcapital.org.br',
      query: 'subject=Ajuda App - Extrato',
    );

    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    }
  }

  void _showStatusHelp() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 230,
          child: Center(
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                          color: Color(0xffBDD8F1), shape: BoxShape.circle),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    const Text(
                      'Em Análise',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: const [
                    Flexible(
                        child: Text(
                      'Seu informe foi recebido e está sendo processado por nossa equipe interna.',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ))
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                          color: Color(0xffF5CFB6), shape: BoxShape.circle),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    const Text(
                      'Cancelado',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: const [
                    Flexible(
                        child: Text(
                      'Sua operação foi cancelada antes que fosse concluída.',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    )),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                          color: Color(0xffBDF1CE), shape: BoxShape.circle),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    const Text(
                      'Concluído',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: const [
                    Flexible(
                        child: Text(
                      'Sua operação foi compensada e finalizada.',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ))
                  ],
                ),
                const Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  GestureDetector(
                      onTap: _sendMailHelp,
                      child: const Text(
                        'Precisa de ajuda? Fale conosco.',
                        style: TextStyle(
                            fontSize: 10,
                            decoration: TextDecoration.underline,
                            color: AppColors.SECONDARY_COLOR),
                      ))
                ])
              ],
            ),
          ),
        );
      },
    );
  }
}
