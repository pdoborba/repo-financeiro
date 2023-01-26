import 'package:equatable/equatable.dart';

import 'withdraw.dart';

abstract class WithdrawState extends Equatable {
  const WithdrawState();

  @override
  List<Object?> get props => [];
}

class WithdrawInitial extends WithdrawState {}

class WithdrawInProgress extends WithdrawState {}

class WithdrawSuccess extends WithdrawState {}

class WithdrawFailure extends WithdrawState {}

// Load

class WithdrawLoadInProgress extends WithdrawState {}

class WithdrawLoadSuccess extends WithdrawState {
  final List<Withdraw> withdraws;

  const WithdrawLoadSuccess(this.withdraws);

  @override
  List<Object?> get props => [withdraws];
}

class WithdrawLoadFailure extends WithdrawState {}

class WithdrawConfirmFailure extends WithdrawState {}

class WithdrawConfirmSuccess extends WithdrawState {}
