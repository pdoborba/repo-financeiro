import 'package:equatable/equatable.dart';

import '../account/account.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];

  List<Account> get accounts => [];
}

class AccountLoadInProgress extends AccountState {}

class AccountLoadSuccess extends AccountState {
  @override
  final List<Account> accounts;

  const AccountLoadSuccess(this.accounts);

  @override
  List<Object?> get props => [accounts];

  @override
  String toString() => 'AccountLoadSuccess { accounts: $accounts }';
}

class AccountLoadFailure extends AccountState {}

class AccountCreateFailure extends AccountState {}

class AccountCreateSuccess extends AccountState {}
