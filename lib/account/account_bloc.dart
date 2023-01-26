import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lpcapital/account/account.dart';
import 'package:lpcapital/account/account_event.dart';

import '../account/repository/account_repository.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository accountRepository;

  ///AccountBloc
  AccountBloc({
    required this.accountRepository,
  }) : super(AccountLoadInProgress());

  @override
  Stream<AccountState> mapEventToState(AccountEvent event) async* {
    if (event is AccountLoad) {
      yield* _mapAccountLoadedToState(event.types);
    } else if (event is AccountCreate) {
      yield* _mapAccountCreateToState(event.account);
    } else if (event is AccountEdit) {
      yield* _mapAccountEditToState(event.account);
    }
  }

  Stream<AccountState> _mapAccountLoadedToState(List<String>? types) async* {
    try {
      yield AccountLoadInProgress();
      var accounts = await accountRepository.listAccounts();
      if (types != null && types.isNotEmpty) {
        yield AccountLoadSuccess(
            accounts.where((element) => types.contains(element.type)).toList());
      } else {
        yield AccountLoadSuccess(accounts);
      }
    } on Exception catch (_) {
      yield AccountLoadFailure();
    }
  }

  Stream<AccountState> _mapAccountCreateToState(Account account) async* {
    List<String> types = account.type == AccountType.COIN.name
        ? [account.type]
        : [AccountType.CORRENTE.name, AccountType.POUPANCA.name];

    try {
      yield AccountLoadInProgress();
      var accountResponse = await accountRepository.createAccount(account);
      if (accountResponse != null) {
        yield AccountCreateSuccess();
      } else {
        yield AccountCreateFailure();
      }
      yield* _mapAccountLoadedToState(types);
    } on Exception catch (_) {
      yield AccountCreateFailure();
      yield* _mapAccountLoadedToState(types);
    }
  }

  Stream<AccountState> _mapAccountEditToState(Account account) async* {
    List<String> types = account.type == AccountType.COIN.name
        ? [account.type]
        : [AccountType.CORRENTE.name, AccountType.POUPANCA.name];

    try {
      yield AccountLoadInProgress();
      var accountResponse = await accountRepository.editAccount(account);
      if (accountResponse != null) {
        yield AccountCreateSuccess();
      } else {
        yield AccountCreateFailure();
      }
      yield* _mapAccountLoadedToState(types);
    } on Exception catch (_) {
      yield AccountCreateFailure();
      yield* _mapAccountLoadedToState(types);
    }
  }
}
