// ignore_for_file: avoid_catches_without_on_clauses, constant_identifier_names

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:lpcapital/account/account_bloc.dart';
import 'package:lpcapital/account/account_event.dart';
import 'package:lpcapital/account/account_state.dart';
import 'package:lpcapital/common/colors.dart';
import 'package:lpcapital/common/widgets/main_button.dart';
import 'package:lpcapital/withdraw/withdraw_bloc.dart';
import 'package:lpcapital/withdraw/withdraw_event.dart';
import 'package:lpcapital/withdraw/withdraw_state.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../account/account.dart';
import '../balance/balance.dart';
import '../balance/balance_bloc.dart';
import '../balance/balance_state.dart';
import '../common/errors.dart';
import '../common/widgets/app_bar_widget.dart';
import 'withdraw_coin_widget.dart';

///WithdrawPage
class WithdrawPage extends StatefulWidget {
  static const routeName = '/withdraw';

  const WithdrawPage({Key? key}) : super(key: key);
  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  int _selectedType = 0;
  bool _hasSelectedType = false;
  AccountLink? _accountLink = AccountLink.INDIVIDUAL;
  AccountType? _accountType = AccountType.CORRENTE;
  Banks? _selectedBank = Banks.BRADESCO;
  PixType? _selectedPixType = PixType.EMAIL;
  Account? _selectedAccount;
  Account? _pickedAccount;
  Account? _selectedAccountToEdit;
  bool _useAllBalance = false;
  bool _addNewAccount = false;
  bool _terms = false;
  Balance? _selectedBalance;

  final TextEditingController _agency = TextEditingController();
  final TextEditingController _cc = TextEditingController();
  final TextEditingController _pix = TextEditingController();
  final MoneyMaskedTextController _value =
      MoneyMaskedTextController(leftSymbol: 'R\$ ');
  final _formatCurrency = NumberFormat.simpleCurrency(locale: 'pt_BR');

  List<Balance>? _lastBalances;

  @override
  void initState() {
    _loadBalance();
    super.initState();
  }

  @override
  void dispose() {
    _agency.dispose();
    _cc.dispose();
    _pix.dispose();
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
          child: _buildWithdrawWidget()),
    );
  }

  Widget _buildWithdrawWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _buildHeaderWidget(),
        // const SizedBox(
        //   height: 32,
        // ),
        ..._hasSelectedType
            ? _buildSelectedTypeWidget()
            : _buildSelectTypeWidget()
      ],
    );
  }

  List<Widget> _buildSelectedTypeWidget() {
    return _selectedType == 0 ? _buildMoneyWidget() : _buildCoinWidget();
  }

  List<Widget> _buildMoneyWidget() {
    if (_selectedAccount != null) {
      return _buildFinishWidget();
    } else {
      return _buildMoneyMainWidget();
    }
  }

  List<Widget> _buildMoneyMainWidget() {
    return [
      BlocConsumer<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoadInProgress) {
            return _buildLoadingWidget();
          } else if (state is AccountLoadSuccess) {
            if (state.accounts.isEmpty || _addNewAccount) {
              return _buildMoneyNewWidget();
            } else {
              return _buildMoneyExisting(state.accounts);
            }
          } else {
            return _buildMoneyNewWidget();
          }
        },
        listener: (context, state) async {
          if (state is AccountCreateFailure) {
            Errors.showError(
                'Falha ao criar conta, favor verifique os dados e tente novamente');
          }
        },
      )
    ];
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
          width: 12,
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
        height: 24,
      ),
      const Text(
        'Selecione sua conta para saque',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
      ),
      const SizedBox(
        height: 16,
      ),
      SizedBox(
        height: (accounts.length + 1) * 100,
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
      ),
      const SizedBox(
        height: 12,
      ),
    ]);
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

  Widget _buildAccountItem(Account account) {
    return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _pickedAccount = account;
              _selectedAccount = account;
            });
          },
          child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: _pickedAccount?.id == account.id
                          ? AppColors.PRIMARY_COLOR
                          : const Color(0xffD4D2D5)),
                  borderRadius: const BorderRadius.all(Radius.circular(16))),
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          account.getBankName(),
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

  Widget _buildMoneyNewWidget() {
    if (_selectedAccountToEdit != null) {
      _selectedBank = Banks.values.byName(_selectedAccountToEdit!.bank);
      _agency.text = _selectedAccountToEdit!.agency;
      _cc.text = _selectedAccountToEdit!.cc;
      _selectedPixType = PixType.values.byName(_selectedAccountToEdit!.pixType);
      _pix.text = _selectedAccountToEdit!.pix;
      _accountType = AccountType.values.byName(_selectedAccountToEdit!.type);
      _accountLink = AccountLink.values.byName(_selectedAccountToEdit!.link);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
        Image(
          image: AssetImage('assets/ic_withdraw.png'),
          color: Colors.grey,
          width: 44,
          height: 40,
        ),
        SizedBox(
          width: 12,
        ),
        Flexible(
          child: Text(
            'Cadastre uma conta de destino',
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
        'Lembrando que a conta deve ser da mesma titularidade.',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
      ),
      DropdownSearch<String>(
        items: Banks.values.map((e) => e.label).toList(),
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: 'Conta',
            hintText: 'Conta',
          ),
        ),
        onChanged: (((value) {
          _selectedBank =
              Banks.values.firstWhere((element) => element.label == value);
        })),
        selectedItem: Banks.BRADESCO.label,
      ),
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Agência',
          hintText: 'Agência',
        ),
        textInputAction: TextInputAction.next,
        controller: _agency,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Por favor digite a agência';
          }
          return null;
        },
      ),
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Conta com dígito',
          hintText: 'Conta com dígito',
        ),
        textInputAction: TextInputAction.next,
        controller: _cc,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Por favor digite a conta com dígito';
          }
          return null;
        },
      ),
      DropdownSearch<String>(
        items: PixType.values.map((e) => e.label).toList(),
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: 'Tipo de Pix',
            hintText: 'Tipo de Pix',
          ),
        ),
        onChanged: (((value) {
          _selectedPixType =
              PixType.values.firstWhere((element) => element.label == value);
        })),
        selectedItem: PixType.EMAIL.label,
      ),
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Código Pix',
          hintText: 'Código Pix',
        ),
        textInputAction: TextInputAction.next,
        controller: _pix,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Por favor digite o código Pix';
          }
          return null;
        },
      ),
      const SizedBox(
        height: 8,
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
                    value: AccountType.CORRENTE.index,
                    groupValue: _accountType?.index ?? 0,
                    onChanged: (index) {
                      setState(() {
                        _accountType = AccountType.values
                            .firstWhere((element) => element.index == index);
                      });
                    }),
                Expanded(child: Text(AccountType.CORRENTE.label))
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Radio(
                    value: AccountType.POUPANCA.index,
                    groupValue: _accountType?.index ?? 0,
                    onChanged: (index) {
                      setState(() {
                        _accountType = AccountType.values
                            .firstWhere((element) => element.index == index);
                      });
                    }),
                Expanded(child: Text(AccountType.POUPANCA.label))
              ],
            ),
          ),
        ],
      ),
      const Text(
        'Vínculo da conta',
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
                    value: AccountLink.INDIVIDUAL.index,
                    groupValue: _accountLink?.index ?? 0,
                    onChanged: (index) {
                      setState(() {
                        _accountLink = AccountLink.values
                            .firstWhere((element) => element.index == index);
                      });
                    }),
                Expanded(child: Text(AccountLink.INDIVIDUAL.label))
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Radio(
                    value: AccountLink.CONJUNTA.index,
                    groupValue: _accountLink?.index ?? 0,
                    onChanged: (index) {
                      setState(() {
                        _accountLink = AccountLink.values
                            .firstWhere((element) => element.index == index);
                      });
                    }),
                Expanded(child: Text(AccountLink.CONJUNTA.label))
              ],
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 8,
      ),
      MainButton(
          message: _selectedAccountToEdit != null ? 'Editar' : 'Cadastrar',
          callback: _registerAccount)
    ]);
  }

  List<Widget> _buildFinishWidget() {
    return [
      const Text(
        'Quanto deseja sacar?',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
      ),
      const SizedBox(
        height: 8,
      ),
      Text(
        'Conta selecionada: ${_selectedAccount?.bank}',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
      ),
      TextButton(
          onPressed: _changeMoneyAccount,
          child: Row(children: const [
            Image(
              image: AssetImage('assets/account_change.png'),
              width: 20,
              height: 20,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              'Trocar de conta',
              style: TextStyle(fontSize: 14, color: AppColors.SECONDARY_COLOR),
            )
          ])),
      Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [_buildBalanceWidget()])),
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

                    if (_getFinalValue() > _getAssetBrlValue('BRL') ||
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
                      _formatCurrency.format(_getAssetBrlValue('BRL'));
                } else {
                  _value.text = _formatCurrency.format(0);
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
        'Taxa de saque: ${_formatCurrency.format(_getWithdrawTax())}',
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
      _buildWithdrawButton()
    ];
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
          return MainButton(
              message: 'Solicitar saque',
              callback: (_getAssetBrlValue('BRL') < _value.numberValue) ||
                      (_getFinalValue() <= 0)
                  ? null
                  : _finishMoney);
        }
      },
      listener: (context, state) {
        if (state is WithdrawSuccess) {
          Errors.showSuccess('Saque requisitado com sucesso');
          Navigator.of(context).pop();
        } else if (state is WithdrawFailure) {
          Errors.showError('Falha ao requisitar saque');
        }
      },
    );
  }

  Widget _buildBalanceWidget() {
    return BlocBuilder<BalanceBloc, BalanceState>(
      builder: (context, state) {
        if (state is BalanceLoadInProgress) {
          return _buildLoadingWidget();
        } else if (state is BalanceLoadFailure) {
          return _buildAvailableBalance();
        } else if (state is BalanceLoadSuccess) {
          _lastBalances = state.balances;
          return _buildAvailableBalance();
        } else {
          return _buildLoadingWidget();
        }
      },
    );
  }

  Widget _buildAvailableBalance() {
    return SizedBox(
      height: 60,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          'Saldo Disponível',
          style: TextStyle(fontSize: 18),
        ),
        Text(
          _formatCurrency.format(_getAssetBrlValue('BRL')),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        )
      ]),
    );
  }

  List<Widget> _buildCoinWidget() {
    return [
      Expanded(
          child: WithdrawCoinWidget(
        callback: _onCoinSelected,
      ))
    ];
  }

  List<Widget> _buildSelectTypeWidget() {
    return [
      _selectedBalance == null
          ? Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
              Image(
                image: AssetImage('assets/ic_withdraw.png'),
                color: Colors.grey,
                width: 44,
                height: 40,
              ),
              SizedBox(
                width: 4,
              ),
              Flexible(
                child: Text(
                  'Selecione a moeda de saque',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff383838)),
                  textAlign: TextAlign.center,
                ),
              ),
            ])
          : const SizedBox.shrink(),
      _selectedBalance == null
          ? const SizedBox(
              height: 16,
            )
          : const SizedBox.shrink(),
      _selectedBalance == null
          ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _buildToggleWidget(),
            ])
          : const SizedBox.shrink(),
      ..._selectedType == 0 ? _buildFirstWidgetCoin() : _buildCoinWidget()
    ];
  }

  List<Widget> _buildFirstWidgetCoin() {
    return [
      const SizedBox(
        height: 32,
      ),
      Row(
        children: const [
          Image(
            image: AssetImage('assets/ic_withdraw_brl_1.png'),
            color: Color(0xff0078B7),
            width: 40,
            height: 40,
          ),
          SizedBox(
            width: 12,
          ),
          Flexible(
            child: Text(
              'A conta de origem deve pertencer a você. Depósitos vindos de outro CPF não serão aceitos. Contas conjuntas devem ser comunicadas ao atendimento antes da transferência.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          )
        ],
      ),
      const SizedBox(
        height: 24,
      ),
      Row(children: const [
        Image(
          image: AssetImage('assets/ic_withdraw_brl_2.png'),
          color: Color(0xff0078B7),
          width: 40,
          height: 40,
        ),
        SizedBox(
          width: 12,
        ),
        Flexible(
          child: Text(
            'TEDs e transferência levam até 1 dia útil para serem aprovados. Docs levam ate 2 dias úteis. PIX podem levar um tempo maior para serem creditados, pois passam por aprovação.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        )
      ]),
      const SizedBox(
        height: 12,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Checkbox(
            activeColor: AppColors.PRIMARY_COLOR,
            value: _terms,
            onChanged: (value) {
              setState(() {
                _terms = value!;
              });
            }),
        const Text(
          'Li e aceito os termos para saque',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        )
      ]),
      const Spacer(),
      MainButton(
          message: 'Continuar', callback: _terms == true ? _selectType : null),
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
    ];
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildToggleWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedType = 0;
            });
          },
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(
              'Reais',
              style: TextStyle(
                  color: _selectedType == 0
                      ? AppColors.PRIMARY_COLOR
                      : Colors.black,
                  fontSize: 20),
            ),
            const SizedBox(
              height: 4,
            ),
            Container(
              height: 3,
              width: 150,
              color: _selectedType == 0
                  ? AppColors.PRIMARY_COLOR
                  : Colors.transparent,
            )
          ]),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedType = 1;
            });
          },
          child: Column(children: [
            Text(
              'Cripto',
              style: TextStyle(
                  color: _selectedType == 1
                      ? AppColors.PRIMARY_COLOR
                      : Colors.black,
                  fontSize: 20),
            ),
            const SizedBox(
              height: 4,
            ),
            Container(
              height: 3,
              width: 150,
              color: _selectedType == 1
                  ? AppColors.PRIMARY_COLOR
                  : Colors.transparent,
            )
          ]),
        ),
      ],
    );
    // return ToggleButtons(
    //   direction: Axis.horizontal,
    //   onPressed: (int index) {
    //     setState(() {
    //       _selectedType = index;
    //     });
    //   },
    //   borderRadius: const BorderRadius.all(Radius.circular(24)),
    //   selectedBorderColor: AppColors.PRIMARY_COLOR,
    //   selectedColor: Colors.white,
    //   fillColor: AppColors.PRIMARY_COLOR,
    //   constraints: const BoxConstraints(
    //     minHeight: 40.0,
    //     minWidth: 150.0,
    //   ),
    //   isSelected: [_selectedType == 0, _selectedType == 1],
    //   children: const [Text('Reais'), Text('Cripto')],
    // );
  }

  Widget _buildHeaderWidget() {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Image(
              image: AssetImage('assets/ic_withdraw.png'),
              color: Colors.grey,
              width: 44,
              height: 40,
            )
          ],
        ));
  }

  void _onCoinSelected(Balance? coin) {
    setState(() {
      _selectedBalance = coin;
    });
  }

  void _selectAccount() {
    setState(() {
      _selectedAccount = _pickedAccount;
    });
  }

  void _selectType() {
    setState(() {
      _hasSelectedType = true;
      _addNewAccount = false;
      Provider.of<AccountBloc>(context, listen: false).add(
          AccountLoad([AccountType.CORRENTE.name, AccountType.POUPANCA.name]));
    });
  }

  void _registerAccount() {
    setState(() {
      if (_selectedBank == null) {
        Errors.showError('Favor selecionar o Banco');
        return;
      }
      if (_agency.text.isEmpty) {
        Errors.showError('Favor preencher a Agência');
        return;
      }
      if (_cc.text.isEmpty) {
        Errors.showError('Favor preencher a Conta com Dígito');
        return;
      }
      if (_selectedPixType == null) {
        Errors.showError('Favor selecionar o Tipo de Pix');
        return;
      }
      if (_pix.text.isEmpty) {
        Errors.showError('Favor preencher o Código Pix');
        return;
      }
      if (_selectedPixType == null) {
        Errors.showError('Favor selecionar o Tipo de Pix');
        return;
      }
      if (_accountType == null) {
        Errors.showError('Favor selecionar o Tipo de Conta');
        return;
      }
      if (_accountLink == null) {
        Errors.showError('Favor selecionar o Vínculo da Conta');
        return;
      }

      _addNewAccount = false;
      if (_selectedAccountToEdit == null) {
        Provider.of<AccountBloc>(context, listen: false).add(AccountCreate(
            Account(
                '',
                '',
                _selectedBank!.name,
                _agency.text,
                _cc.text,
                _selectedPixType!.name,
                _pix.text,
                _accountType!.name,
                _accountLink!.name,
                '',
                '')));
      } else {
        Provider.of<AccountBloc>(context, listen: false).add(AccountEdit(
            Account(
                _selectedAccountToEdit!.id,
                _selectedAccountToEdit!.email,
                _selectedBank!.name,
                _agency.text,
                _cc.text,
                _selectedPixType!.name,
                _pix.text,
                _accountType!.name,
                _accountLink!.name,
                _selectedAccountToEdit!.createdAt,
                _selectedAccountToEdit!.updatedAt)));
      }
    });
  }

  void _changeMoneyAccount() {
    setState(() {
      _selectedAccount = null;
    });
  }

  void _addAccount() {
    setState(() {
      _selectedAccount = null;
      _addNewAccount = true;
    });
  }

  void _editAccount(Account account) {
    setState(() {
      _selectedAccountToEdit = account;
      _addNewAccount = true;
    });
  }

  void _finishMoney() {
    Provider.of<WithdrawBloc>(context, listen: false).add(WithdrawBrl(
        _selectedAccount?.id ?? '', _value.numberValue, _getWithdrawTax()));
  }

  void _loadBalance() {
    Provider.of<BalanceBloc>(context, listen: false)
        .add(BalanceEvents.BalanceInitial);
    Provider.of<BalanceBloc>(context, listen: false)
        .add(BalanceEvents.BalanceLoad);
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

  num _getAssetBrlValue(String? asset) {
    if (_lastBalances != null && _lastBalances!.isNotEmpty) {
      num totalBrl = 0;
      for (Balance balance in _lastBalances ?? []) {
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
    return 2.5;
  }

  num _getFinalValue() {
    return _value.numberValue - _getWithdrawTax();
  }
}
