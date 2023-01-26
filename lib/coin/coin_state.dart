import 'package:equatable/equatable.dart';
import 'package:lpcapital/coin/coin_network.dart';

abstract class CoinState extends Equatable {
  const CoinState();

  @override
  List<Object?> get props => [];
}

class CoinInitial extends CoinState {
  @override
  List<Object?> get props => [];
}

// Load
class CoinLoadInProgress extends CoinState {}

class CoinLoadSuccess extends CoinState {
  final List<CoinNetwork> coins;

  const CoinLoadSuccess(this.coins);

  @override
  List<Object?> get props => [coins];
}

class CoinLoadFailure extends CoinState {}
