import 'package:equatable/equatable.dart';

abstract class CoinEvent extends Equatable {
  const CoinEvent();
}

class CoinLoad extends CoinEvent {
  @override
  List<Object?> get props => [];
}
