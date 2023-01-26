import 'package:equatable/equatable.dart';

abstract class WithdrawEvent extends Equatable {
  const WithdrawEvent();
}

class WithdrawBrl extends WithdrawEvent {
  final String accountId;
  final num value;
  final num tax;

  const WithdrawBrl(this.accountId, this.value, this.tax);

  @override
  List<Object?> get props => [accountId, value, tax];
}

class WithdrawCoin extends WithdrawEvent {
  final String accountId;
  final String asset;
  final String network;
  final num value;
  final num tax;

  const WithdrawCoin(
      this.accountId, this.asset, this.network, this.value, this.tax);

  @override
  List<Object?> get props => [accountId, asset, network, value, tax];
}

class WithdrawLoad extends WithdrawEvent {
  @override
  List<Object?> get props => [];
}

class WithdrawConfirm extends WithdrawEvent {
  final String id;

  const WithdrawConfirm(this.id);

  @override
  List<Object?> get props => [id];
}

class WithdrawCancel extends WithdrawEvent {
  final String id;

  const WithdrawCancel(this.id);

  @override
  List<Object?> get props => [id];
}
