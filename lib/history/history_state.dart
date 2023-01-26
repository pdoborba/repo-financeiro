import 'package:equatable/equatable.dart';

import 'history.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];

  History? get history => null;
}

class HistoryLoadInProgress extends HistoryState {}

class HistoryLoadSuccess extends HistoryState {
  @override
  final History history;

  const HistoryLoadSuccess(this.history);

  @override
  List<Object?> get props => [history];

  @override
  String toString() => 'HistoryLoadSuccess { history: $history }';
}

class HistoryLoadFailure extends HistoryState {}
