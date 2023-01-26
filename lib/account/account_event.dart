import 'package:equatable/equatable.dart';

import 'account.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();
}

class AccountLoad extends AccountEvent {
  final List<String>? types;

  const AccountLoad(this.types);

  @override
  List<Object?> get props => [types];
}

class AccountCreate extends AccountEvent {
  final Account account;

  const AccountCreate(this.account);

  @override
  List<Object?> get props => [account];
}

class AccountEdit extends AccountEvent {
  final Account account;

  const AccountEdit(this.account);

  @override
  List<Object?> get props => [account];
}
