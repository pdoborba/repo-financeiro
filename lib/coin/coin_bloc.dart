import 'package:flutter_bloc/flutter_bloc.dart';
import 'repository/coin_repository.dart';
import 'coin_event.dart';
import 'coin_state.dart';

class CoinBloc extends Bloc<CoinEvent, CoinState> {
  final CoinRepository coinRepository;

  ///CoinBloc
  CoinBloc({
    required this.coinRepository,
  }) : super(CoinInitial());

  @override
  Stream<CoinState> mapEventToState(CoinEvent event) async* {
    if (event is CoinLoad) {
      yield* _mapCoinLoadToState();
    }
  }

  Stream<CoinState> _mapCoinLoadToState() async* {
    try {
      yield CoinLoadInProgress();
      var result = await coinRepository.getAll();
      yield CoinLoadSuccess(result);
    } on Exception catch (_) {
      yield CoinLoadFailure();
    }
  }
}
