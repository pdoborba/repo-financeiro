import 'package:flutter_bloc/flutter_bloc.dart';

import 'history_state.dart';
import 'repository/history_repository.dart';

// Define all possible events for the history
// ignore: constant_identifier_names
enum HistoryEvents { HistoryLoad, HistoryInitial }

class HistoryBloc extends Bloc<HistoryEvents, HistoryState> {
  final HistoryRepository historyRepository;

  ///HistoryBloc
  HistoryBloc({
    required this.historyRepository,
  }) : super(HistoryLoadInProgress());

  @override
  Stream<HistoryState> mapEventToState(HistoryEvents event) async* {
    switch (event) {
      case HistoryEvents.HistoryLoad:
        yield* _mapHistoryLoadedToState();
        break;
      case HistoryEvents.HistoryInitial:
        yield HistoryLoadInProgress();
        break;
    }
  }

  Stream<HistoryState> _mapHistoryLoadedToState() async* {
    try {
      var history = await historyRepository.loadHistory();
      if (history != null) {
        yield HistoryLoadSuccess(history);
      } else {
        yield HistoryLoadFailure();
      }
    } on Exception catch (_) {
      yield HistoryLoadFailure();
    }
  }
}
