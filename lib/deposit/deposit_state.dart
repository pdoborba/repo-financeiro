import 'package:equatable/equatable.dart';

import 'deposit.dart';

abstract class DepositState extends Equatable {
  const DepositState();

  @override
  List<Object?> get props => [];
}

class DepositInitial extends DepositState {}

class DepositInProgress extends DepositState {}

class DepositSuccess extends DepositState {}

class DepositFailure extends DepositState {}

// Load
class DepositLoadInProgress extends DepositState {}

class DepositLoadSuccess extends DepositState {
  final List<Deposit> deposits;

  const DepositLoadSuccess(this.deposits);

  @override
  List<Object?> get props => [deposits];
}

class DepositLoadFailure extends DepositState {}

class DepositConfirmFailure extends DepositState {}

class DepositConfirmSuccess extends DepositState {}

class DepositCancelFailure extends DepositState {}

class DepositCancelSuccess extends DepositState {}
