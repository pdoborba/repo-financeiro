// ignore_for_file: avoid_catches_without_on_clauses, constant_identifier_names

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lpcapital/coin/coin.dart';
import 'package:lpcapital/coin/coin_bloc.dart';
import 'package:lpcapital/coin/coin_event.dart';
import 'package:lpcapital/coin/coin_network.dart';
import 'package:lpcapital/coin/coin_state.dart';
import 'package:lpcapital/network/network.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';

import '../account/account.dart';
import '../account/account_bloc.dart';
import '../account/account_event.dart';
import '../account/account_state.dart';
import '../balance/balance.dart';
import '../balance/balance_bloc.dart';
import '../balance/balance_state.dart';
import '../common/colors.dart';
import '../common/errors.dart';
import '../common/widgets/main_button.dart';
import 'withdraw_bloc.dart';
import 'withdraw_event.dart';
import 'withdraw_state.dart';

///WithdrawCoinWidget
class WithdrawCoinWidget extends StatefulWidget {
  final Function(Balance coin) callback;
  const WithdrawCoinWidget({Key? key, required this.callback})
      : super(key: key);
  @override
  _WithdrawCoinWidgetState createState() => _WithdrawCoinWidgetState();
}

class _WithdrawCoinWidgetState extends State<WithdrawCoinWidget> {
  Balance? _selectedBalance;
  List<Balance>? _balances;

  List<CoinNetwork>? _coinNetworks;
  Network? _selectedNetwork;

  Account? _selectedAccount;
  bool _addNewAccount = false;
  Account? _selectedAccountToEdit;

  bool _useAllBalance = false;
  bool _acceptedTerms = false;

  final TextEditingController _name = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _value = TextEditingController();

  final _formatCurrency = NumberFormat.simpleCurrency(locale: 'pt_BR');

  @override
  void initState() {
    Provider.of<CoinBloc>(context, listen: false).add(CoinLoad());
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _value.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: _buildNetworkWidget(),
    );
  }

  Widget _buildMainWidget() {
    if (_selectedBalance == null) {
      return _buildBalancesWidget();
    } else {
      return _buildAccountMainWidget();
    }
  }

  Widget _buildFinishWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
        'Quanto deseja sacar?',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
      ),
      const SizedBox(
        height: 16,
      ),
      _buildAvailableBalanceForAsset(),
      const SizedBox(
        height: 16,
      ),
      Row(
        children: [
          const Expanded(
              flex: 2,
              child: Text(
                'Quantidade',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.PRIMARY_COLOR),
              )),
          Expanded(
              flex: 4,
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
                    if (_getFinalValue() >
                            _getAssetValue(_selectedBalance!.asset) ||
                        _getFinalValue() < 0) {
                      return 'O valor sacado deve ser menor que o disponível';
                    }
                    return null;
                  },
                ),
              ))
        ],
      ),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Checkbox(
            activeColor: AppColors.PRIMARY_COLOR,
            value: _useAllBalance,
            onChanged: (value) {
              setState(() {
                _useAllBalance = value!;
                if (_useAllBalance == true) {
                  _value.text =
                      _getAssetValue(_selectedBalance!.asset).toString();
                } else {
                  _value.text = '0';
                }
              });
            }),
        const Text(
          'Usar todo o saldo disponível',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        )
      ]),
      const SizedBox(
        height: 16,
      ),
      Text(
        'Taxa de saque ${_selectedBalance!.asset}: ${_getWithdrawTax()}',
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
        '${_selectedBalance!.asset} ${_getFinalValue().toStringAsPrecision(9)}',
        style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.SECONDARY_COLOR),
      ),
      Text(
        _formatCurrency.format(
            _getValueAsAsset(_selectedBalance!.asset, _getFinalValue())),
        style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.SECONDARY_COLOR),
      ),
      const Spacer(),
      _buildWithdrawButton(),
    ]);
  }

  Widget _buildWithdrawButton() {
    return BlocConsumer<WithdrawBloc, WithdrawState>(
      builder: (context, state) {
        if (state is WithdrawInProgress) {
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
          double value = 0;
          if (_value.text.isNotEmpty) {
            value = double.parse(_value.text.replaceAll(',', '.'));
          }

          return MainButton(
              message: 'Solicitar saque',
              callback: (_getAssetValue(_selectedBalance!.asset) < value) ||
                      (_getFinalValue() <= 0)
                  ? null
                  : _finishCoin);
        }
      },
      listener: (context, state) {
        if (state is WithdrawSuccess) {
          Errors.showSuccess('Saque realizado com sucesso');
          Navigator.of(context).pop();
        } else if (state is WithdrawFailure) {
          Errors.showError('Falha ao realizar saque');
        }
      },
    );
  }

  Widget _buildAccountMainWidget() {
    if (_selectedAccount != null) {
      return _buildFinishWidget();
    } else {
      return _buildAccountsWidget();
    }
  }

  Widget _buildAccountsWidget() {
    return BlocConsumer<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is AccountLoadInProgress) {
          return _buildLoadingWidget();
        } else if (state is AccountLoadSuccess) {
          if (state.accounts.isEmpty || _addNewAccount) {
            return _buildCoinNewWidget();
          } else {
            return _buildMoneyExisting(state.accounts
                .where((element) =>
                    (element.type == AccountType.CORRENTE.name &&
                        _selectedBalance?.asset == 'BRL') ||
                    (element.bank == _selectedBalance?.asset))
                .toList());
          }
        } else {
          return _buildCoinNewWidget();
        }
      },
      listener: (context, state) async {
        if (state is AccountCreateFailure) {
          Errors.showError(
              'Falha ao criar conta, favor verifique os dados e tente novamente');
        }
      },
    );
  }

  Widget _buildMoneyExisting(List<Account> accounts) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
        Image(
          image: AssetImage('assets/ic_withdraw.png'),
          color: Colors.grey,
          width: 44,
          height: 40,
        ),
        SizedBox(
          width: 8,
        ),
        Flexible(
          child: Text(
            'Contas Cadastradas',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xff383838)),
            textAlign: TextAlign.center,
          ),
        ),
      ]),
      const SizedBox(
        height: 16,
      ),
      const Text(
        'Selecione sua conta para saque',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),
      const SizedBox(
        height: 16,
      ),
      SizedBox(
        height: (accounts.length * 136) + 50,
        child: ListView.builder(
          itemCount: accounts.length + 1,
          itemBuilder: (context, index) {
            if (index == accounts.length) {
              return _buildAddAccountWidget();
            } else {
              return _buildAccountItem(accounts[index]);
            }
          },
        ),
      )
    ]);
  }

  Widget _buildAccountItem(Account account) {
    return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedAccount = account;
              _selectedNetwork = _getNetworks().firstWhereOrNull(
                  (element) => element.network == _selectedBalance!.asset);
            });
          },
          child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: const BorderRadius.all(Radius.circular(16))),
              height: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          account.bank,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w400),
                        ),
                        GestureDetector(
                          onTap: () => _editAccount(account),
                          child: const Image(
                            image: AssetImage('assets/account_change.png'),
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ]),
                  Text(
                    account.agency,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    account.cc,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400),
                  )
                ],
              )),
        ));
  }

  Widget _buildAddAccountWidget() {
    return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: InkWell(
            onTap: _addAccount,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.add_circle_outline,
                  color: AppColors.PRIMARY_COLOR,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Cadastrar nova conta',
                  style: TextStyle(
                    color: AppColors.PRIMARY_COLOR,
                  ),
                )
              ],
            )));
  }

  Widget _buildCoinNewWidget() {
    if (_selectedAccountToEdit != null) {
      _name.text = _selectedAccountToEdit!.agency;
      _address.text = _selectedAccountToEdit!.cc;
      _selectedNetwork = _getNetworks().firstWhereOrNull(
          (element) => element.network == _selectedAccountToEdit!.pix);
    }

    Coin coin = Coin.values.byName(_selectedBalance!.asset.toUpperCase());
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
        Image(
          image: AssetImage('assets/ic_withdraw.png'),
          color: Colors.grey,
          width: 44,
          height: 40,
        ),
        SizedBox(
          width: 8,
        ),
        Flexible(
          child: Text(
            'Cadastre um endereço para saque',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xff383838)),
            textAlign: TextAlign.center,
          ),
        ),
      ]),
      const SizedBox(
        height: 16,
      ),
      Text(
        'Importante validar a rede do endereço de destino. '
        'Rede para saques ${coin.name}: ${_getNetworks().map((e) => e.network)}',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Nome do endereço',
          hintText: 'Nome do endereço',
        ),
        textInputAction: TextInputAction.next,
        controller: _name,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Por favor digite o nome do endereço';
          }
          return null;
        },
      ),
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Endereço / hash (endereço de destino)',
          hintText: 'Endereço / hash (endereço de destino)',
        ),
        textInputAction: TextInputAction.next,
        controller: _address,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Por favor digite o endereço de destino';
          }
          return null;
        },
      ),
      const SizedBox(
        height: 16,
      ),
      _buildAvailableNetworks(),
      const Spacer(),
      MainButton(
          message: _selectedAccountToEdit != null ? 'Editar' : 'Cadastrar',
          callback: _registerAccount)
    ]);
  }

  Widget _buildNetworkWidget() {
    return BlocBuilder<CoinBloc, CoinState>(builder: (context, state) {
      if (state is CoinLoadInProgress) {
        return _buildLoadingWidget();
      } else if (state is CoinLoadFailure) {
        return const Text('Falha ao carregar dados');
      } else if (state is CoinLoadSuccess) {
        _coinNetworks = state.coins;
        return _buildMainWidget();
      } else {
        return _buildLoadingWidget();
      }
    });
  }

  Widget _buildAvailableNetworks() {
    if (_selectedNetwork != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rede selecionada: ${_selectedNetwork!.coin} - ${_selectedNetwork!.network}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(
            height: 8,
          ),
          GestureDetector(
              onTap: () {
                setState(() {
                  _selectedNetwork = null;
                  _selectedAccountToEdit?.pix = '';
                });
              },
              child: Row(children: const [
                Image(
                  height: 16,
                  width: 16,
                  color: Color(0xffD4D2D5),
                  image: AssetImage('assets/ic_network_change.png'),
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Trocar de rede',
                  style: TextStyle(color: Color(0xffD4D2D5), fontSize: 14),
                )
              ]))
        ],
      );
    } else {
      return DropdownSearch<String>(
        items: _getNetworks().map((e) => e.network).toList(),
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: 'Selecionar Rede',
            hintText: 'Selecionar Rede',
          ),
        ),
        onChanged: (((value) {
          setState(() {
            _selectedNetwork = _getNetworks()
                .firstWhere((element) => element.network == value);
            _selectedAccountToEdit?.pix = _selectedNetwork?.network ?? '';
          });
        })),
        selectedItem: _selectedNetwork?.network,
      );
    }
  }

  Widget _buildBalancesWidget() {
    return BlocBuilder<BalanceBloc, BalanceState>(
      builder: (context, state) {
        if (state is BalanceLoadInProgress) {
          return _buildLoadingWidget();
        } else if (state is BalanceLoadFailure) {
          return _buildAvailableBalance();
        } else if (state is BalanceLoadSuccess) {
          _balances = state.balances
              .where((element) => element.asset != 'BRL')
              .toList();
          return _buildAvailableBalance();
        } else {
          return _buildLoadingWidget();
        }
      },
    );
  }

  Widget _buildAvailableBalanceForAsset() {
    return SizedBox(
      height: 100,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          'Saldo Disponível',
          style: TextStyle(fontSize: 18),
        ),
        Text(
          '${_selectedAccount?.bank} ${_getAssetValue(_selectedAccount?.bank)}',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        Text(
          _formatCurrency.format(_getAssetBrlValue(_selectedAccount?.bank)),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        )
      ]),
    );
  }

  Widget _buildAvailableBalance() {
    return Container(
        padding: const EdgeInsets.all(16),
        // decoration: BoxDecoration(
        //     border: Border.all(color: Colors.grey),
        //     borderRadius: const BorderRadius.all(Radius.circular(16))),
        child: ListView.builder(
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  index == 0
                      ? const Divider(
                          thickness: 2,
                          color: Color(0xff383838),
                        )
                      : const SizedBox.shrink(),
                  _buildAssetItem(_balances?[index]),
                  index == _balances!.length - 1
                      ? const Divider(
                          thickness: 2,
                          color: Color(0xff383838),
                        )
                      : const Divider()
                ],
              );
            },
            // separatorBuilder: (context, index) {
            //   return const Divider();
            // },
            itemCount: _balances?.length ?? 0));
  }

  Widget _buildAssetItem(Balance? balance) {
    if (balance == null) {
      return const Text('Moeda não encontrada');
    }

    Coin? coin = Coin.values.firstWhereOrNull(
        (element) => element.shortName == balance.asset.toUpperCase());

    if (coin == null) {
      return const SizedBox();
    }

    return GestureDetector(
        onTap: () => _selectBalance(balance),
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Image(
                  height: 24,
                  width: 24,
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
                      coin.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      balance.asset,
                      style: const TextStyle(fontSize: 14),
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
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatCurrency.format(balance.asset == 'BRL'
                            ? balance.free
                            : balance.brlFree),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ))
            ],
          ),
        ));
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<bool> _showAlertDialog() async {
    _acceptedTerms = false;

    var result = await showDialog<bool>(
        context: context,
        builder: ((context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                child: SizedBox(
              height: 400,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.warning,
                            color: Colors.orange,
                            size: 60,
                          ),
                        ]),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        _selectedBalance!.asset,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ]),
                    const SizedBox(
                      height: 8,
                    ),
                    RichText(
                      text: const TextSpan(
                        text: 'Envios de criptomoeda',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text: ' não podem ser cancelados.',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Envie somente para rede ',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text: '${_selectedNetwork?.network}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const TextSpan(
                              text:
                                  '. Enviar para outro tipo de rede irá resultar em'),
                          const TextSpan(
                              text: ' PERDA PERMANENTE DE SEU SALDO.',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Taxa de envio',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text:
                                  ' ${_selectedNetwork?.withdrawFee} ${_selectedNetwork?.coin}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Checkbox(
                          activeColor: AppColors.PRIMARY_COLOR,
                          value: _acceptedTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptedTerms = value!;
                            });
                          }),
                      const Flexible(
                          child: Text(
                        'Declaro ter lido as orientações e estou ciente das regras de transferência.',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      )),
                    ]),
                    const Spacer(),
                    MainButton(
                        message: 'Continuar',
                        callback: !_acceptedTerms ? null : _closeDialog),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
            ));
          });
        }));

    return result == true;
  }

  void _closeDialog() {
    Navigator.pop(context, true);
  }

  void _addAccount() {
    setState(() {
      _selectedAccount = null;
      _addNewAccount = true;
    });
  }

  num _getAssetValue(String? asset) {
    if (_balances != null && _balances!.isNotEmpty) {
      num total = 0;
      for (Balance balance in _balances ?? []) {
        if (asset != null &&
            balance.asset.toLowerCase() != asset.toLowerCase()) {
          continue;
        }
        total += balance.free ?? 0;
      }
      return total;
    } else {
      return 0;
    }
  }

  num _getAssetBrlValue(String? asset) {
    if (_balances != null && _balances!.isNotEmpty) {
      num totalBrl = 0;
      for (Balance balance in _balances ?? []) {
        if (asset != null &&
            balance.asset.toLowerCase() != asset.toLowerCase()) {
          continue;
        }
        totalBrl += asset?.toUpperCase() == 'BRL'
            ? balance.free ?? 0
            : balance.brlFree ?? 0;
      }
      return totalBrl;
    } else {
      return 0;
    }
  }

  num _getWithdrawTax() {
    return _selectedNetwork?.withdrawFee ?? 0;
  }

  num _getFinalValue() {
    if (_value.text.isNotEmpty) {
      return double.parse(_value.text.replaceAll(',', '.')) - _getWithdrawTax();
    } else {
      return 0 - _getWithdrawTax();
    }
  }

  num _getValueAsAsset(String asset, num assetValue) {
    if (_balances != null && _balances!.isNotEmpty) {
      var selectedBalance = _balances?.firstWhere(
          (element) => element.asset.toLowerCase() == asset.toLowerCase());
      if (selectedBalance != null) {
        if (selectedBalance.free! > 0) {
          var multiplier =
              (selectedBalance.brlFree ?? 0) / (selectedBalance.free ?? 1);
          return assetValue * multiplier;
        }
        return 0;
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

  void _editAccount(Account account) {
    setState(() {
      _selectedAccountToEdit = account;
      _addNewAccount = true;
    });
  }

  void _finishCoin() async {
    var result = await _showAlertDialog();
    if (result == true) {
      Provider.of<WithdrawBloc>(context, listen: false).add(WithdrawCoin(
          _selectedAccount!.id,
          _selectedBalance!.asset,
          _selectedNetwork?.network ?? '',
          double.parse(_value.text.replaceAll(',', '.')),
          _getWithdrawTax()));
    }
  }

  void _registerAccount() {
    setState(() {
      if (_selectedBalance == null) {
        Errors.showError('Favor selecionar a moeda');
        return;
      }
      if (_name.text.isEmpty) {
        Errors.showError('Favor preencher o nome');
        return;
      }
      if (_address.text.isEmpty) {
        Errors.showError('Favor preencher o endereço');
        return;
      }

      if (_selectedNetwork == null) {
        Errors.showError('Favor selecionar a rede');
        return;
      }

      _addNewAccount = false;
      if (_selectedAccountToEdit == null) {
        Provider.of<AccountBloc>(context, listen: false).add(AccountCreate(
            Account(
                '',
                '',
                _selectedBalance?.asset ?? '',
                _name.text,
                _address.text,
                '',
                _selectedNetwork?.network ?? '',
                AccountType.COIN.name,
                '',
                '',
                '')));
      } else {
        Provider.of<AccountBloc>(context, listen: false).add(AccountEdit(
            Account(
                _selectedAccountToEdit!.id,
                _selectedAccountToEdit!.email,
                _selectedBalance?.asset ?? '',
                _name.text,
                _address.text,
                '',
                _selectedNetwork?.network ?? '',
                AccountType.COIN.name,
                '',
                _selectedAccountToEdit!.createdAt,
                _selectedAccountToEdit!.updatedAt)));
      }
    });
  }

  void _selectBalance(Balance balance) {
    setState(() {
      Provider.of<AccountBloc>(context, listen: false)
          .add(AccountLoad([AccountType.COIN.name]));

      _selectedBalance = balance;
      widget.callback(_selectedBalance!);
    });
  }

  List<Network> _getNetworks() {
    List<Network> networks = [];
    if (_coinNetworks != null) {
      for (var coinNetwork in _coinNetworks!) {
        if (coinNetwork.coin == _selectedBalance?.asset) {
          for (var network in coinNetwork.networkList) {
            if (network.withdrawEnable == true) {
              networks.add(network);
            }
          }
        }
      }
    }

    return networks;
  }

  void _sendMailHelp() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'admin@lpcapital.org.br',
      query: 'subject=Ajuda App - Saque',
    );

    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    }
  }
}
