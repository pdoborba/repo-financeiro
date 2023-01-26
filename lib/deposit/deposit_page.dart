// ignore_for_file: avoid_catches_without_on_clauses, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:lpcapital/common/colors.dart';
import 'package:lpcapital/common/widgets/main_button.dart';
import 'package:lpcapital/deposit/deposit.dart';
import 'package:lpcapital/deposit/deposit_bloc.dart';
import 'package:lpcapital/deposit/deposit_event.dart';
import 'package:lpcapital/deposit/deposit_state.dart';
import 'package:provider/provider.dart';

import '../common/errors.dart';
import '../common/widgets/app_bar_widget.dart';

///DepositPage
class DepositPage extends StatefulWidget {
  static const routeName = '/deposit';

  const DepositPage({Key? key}) : super(key: key);
  @override
  _DepositPageState createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final MoneyMaskedTextController _value =
      MoneyMaskedTextController(leftSymbol: 'R\$ ');
  final _formatCurrency = NumberFormat.simpleCurrency(locale: 'pt_BR');
  DepositType _depositType = DepositType.TED;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
          child: _buildDepositWidget()),
    );
  }

  Widget _buildDepositWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderWidget(),
        const SizedBox(
          height: 24,
        ),
        const Text(
          'Depósito',
          style: TextStyle(
              fontSize: 28,
              color: AppColors.PRIMARY_COLOR,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(
          height: 32,
        ),
        ..._buildFinishWidget(),
      ],
    );
  }

  List<Widget> _buildFinishWidget() {
    return [
      const Text(
        'Quanto deseja depositar?',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
      ),
      const SizedBox(
        height: 16,
      ),
      const Text(
        'Tipo de Conta',
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.PRIMARY_COLOR),
      ),
      Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Radio(
                    value: DepositType.TED.index,
                    groupValue: _depositType.index,
                    onChanged: (index) {
                      setState(() {
                        _depositType = DepositType.values
                            .firstWhere((element) => element.index == index);
                      });
                    }),
                Expanded(child: Text(DepositType.TED.name))
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Radio(
                    value: DepositType.PIX.index,
                    groupValue: _depositType.index,
                    onChanged: (index) {
                      setState(() {
                        _depositType = DepositType.values
                            .firstWhere((element) => element.index == index);
                      });
                    }),
                Expanded(child: Text(DepositType.PIX.name))
              ],
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 8,
      ),
      Row(
        children: [
          const Expanded(
              flex: 1,
              child: Text(
                'Valor R\$',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.PRIMARY_COLOR),
              )),
          Expanded(
              flex: 3,
              child: SizedBox(
                height: 30,
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {});
                  },
                  keyboardType: TextInputType.number,
                  cursorColor: AppColors.PRIMARY_COLOR,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      borderSide: BorderSide(color: AppColors.PRIMARY_COLOR),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      borderSide: BorderSide(color: AppColors.PRIMARY_COLOR),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      borderSide: BorderSide(color: AppColors.PRIMARY_COLOR),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  controller: _value,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor digite o valor';
                    }

                    return null;
                  },
                ),
              ))
        ],
      ),
      const SizedBox(
        height: 16,
      ),
      Text(
        'Taxa de transação: ${_formatCurrency.format(_getDepositTax())}',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
      ),
      const SizedBox(
        height: 32,
      ),
      const Text(
        'Valor total a receber',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
      ),
      Text(
        _formatCurrency.format(_getFinalValue()),
        style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.SECONDARY_COLOR),
      ),
      const Spacer(),
      _buildDepositButton()
    ];
  }

  Widget _buildDepositButton() {
    return BlocConsumer<DepositBloc, DepositState>(
      builder: (context, state) {
        if (state is DepositInProgress) {
          return Container(
              decoration: const BoxDecoration(
                color: AppColors.BUTTON_COLOR,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: Center(
                  child: Transform.scale(
                      scale: 0.5,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                      ))));
        } else {
          return MainButton(
              message: 'Continuar',
              callback: _getFinalValue() <= 0 ? null : _finishMoney);
        }
      },
      listener: (context, state) {
        if (state is DepositSuccess) {
          Errors.showSuccess('Depósito requisitado com sucesso');
          Navigator.of(context).pop();
        } else if (state is DepositFailure) {
          Errors.showError('Falha ao requisitar depósito');
        }
      },
    );
  }

  Widget _buildHeaderWidget() {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Image(
              image: AssetImage('assets/ic_deposit.png'),
              color: Colors.grey,
              width: 44,
              height: 40,
            )
          ],
        ));
  }

  void _finishMoney() {
    Provider.of<DepositBloc>(context, listen: false)
        .add(DepositBrl(_value.numberValue, 'BRL', _depositType));
  }

  num _getDepositTax() {
    return 0;
  }

  num _getFinalValue() {
    return _value.numberValue - _getDepositTax();
  }
}
