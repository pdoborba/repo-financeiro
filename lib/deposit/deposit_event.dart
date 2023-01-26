import 'package:equatable/equatable.dart';
import 'package:lpcapital/deposit/deposit.dart';

abstract class DepositEvent extends Equatable {
  const DepositEvent();
}

class DepositBrl extends DepositEvent {
  final num value;
  final String asset;
  final DepositType type;

  const DepositBrl(this.value, this.asset, this.type);

  @override
  List<Object?> get props => [value, asset, type];
}

class DepositLoad extends DepositEvent {
  @override
  List<Object?> get props => [];
}

class DepositConfirm extends DepositEvent {
  final String id;

  const DepositConfirm(this.id);

  @override
  List<Object?> get props => [id];
}

class DepositCancel extends DepositEvent {
  final String id;

  const DepositCancel(this.id);

  @override
  List<Object?> get props => [id];
}
