import 'package:equatable/equatable.dart';

import 'balance.dart';

abstract class BalanceState extends Equatable {
  const BalanceState();

  @override
  List<Object?> get props => [];

  List<Balance> get balances => [];
}

class BalanceLoadInProgress extends BalanceState {}

class BalanceLoadSuccess extends BalanceState {
  @override
  final List<Balance> balances;

  const BalanceLoadSuccess(this.balances);

  @override
  List<Object?> get props => [balances];

  @override
  String toString() => 'BalanceLoadSuccess { balances: $balances }';
}

class BalanceLoadFailure extends BalanceState {}
