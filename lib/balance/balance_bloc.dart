import 'package:flutter_bloc/flutter_bloc.dart';

import 'balance_state.dart';
import 'repository/balance_repository.dart';

// Define all possible events for the balance
// ignore: constant_identifier_names
enum BalanceEvents { BalanceLoad, BalanceInitial }

class BalanceBloc extends Bloc<BalanceEvents, BalanceState> {
  final BalanceRepository balanceRepository;

  ///BalanceBloc
  BalanceBloc({
    required this.balanceRepository,
  }) : super(BalanceLoadInProgress());

  @override
  Stream<BalanceState> mapEventToState(BalanceEvents event) async* {
    switch (event) {
      case BalanceEvents.BalanceLoad:
        yield* _mapBalanceLoadedToState();
        break;
      case BalanceEvents.BalanceInitial:
        yield BalanceLoadInProgress();
        break;
    }
  }

  Stream<BalanceState> _mapBalanceLoadedToState() async* {
    try {
      var balance = await balanceRepository.loadBalance(null);
      yield BalanceLoadSuccess(balance);
    } on Exception catch (_) {
      yield BalanceLoadFailure();
    }
  }
}
