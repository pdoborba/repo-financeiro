import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lpcapital/deposit/deposit.dart';
import 'repository/deposit_repository.dart';
import 'deposit_event.dart';
import 'deposit_state.dart';

class DepositBloc extends Bloc<DepositEvent, DepositState> {
  final DepositRepository depositRepository;

  ///DepositBloc
  DepositBloc({
    required this.depositRepository,
  }) : super(DepositInitial());

  @override
  Stream<DepositState> mapEventToState(DepositEvent event) async* {
    if (event is DepositBrl) {
      yield* _mapDepositToState(event.value, event.asset, event.type);
    } else if (event is DepositLoad) {
      yield* _mapDepositLoadToState();
    } else if (event is DepositConfirm) {
      yield* _mapDepositConfirmToState(event.id);
    } else if (event is DepositCancel) {
      yield* _mapDepositCancelToState(event.id);
    }
  }

  Stream<DepositState> _mapDepositConfirmToState(String id) async* {
    try {
      yield DepositLoadInProgress();
      var result = await depositRepository.confirmDeposit(id);
      if (result == true) {
        yield DepositConfirmSuccess();
      } else {
        yield DepositConfirmFailure();
      }
      yield* _mapDepositLoadToState();
    } on Exception catch (_) {
      yield DepositConfirmFailure();
    }
  }

  Stream<DepositState> _mapDepositCancelToState(String id) async* {
    try {
      yield DepositLoadInProgress();
      var result = await depositRepository.cancelDeposit(id);
      if (result == true) {
        yield DepositCancelSuccess();
      } else {
        yield DepositCancelFailure();
      }
      yield* _mapDepositLoadToState();
    } on Exception catch (_) {
      yield DepositCancelFailure();
    }
  }

  Stream<DepositState> _mapDepositLoadToState() async* {
    try {
      yield DepositLoadInProgress();
      var result = await depositRepository.listDeposits();
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      yield DepositLoadSuccess(result);
    } on Exception catch (_) {
      yield DepositLoadFailure();
    }
  }

  Stream<DepositState> _mapDepositToState(
    num value,
    String asset,
    DepositType type,
  ) async* {
    try {
      yield DepositInProgress();
      var result =
          await depositRepository.createDeposit(value, 'BRL', type.name);
      if (result == true) {
        yield DepositSuccess();
      } else {
        yield DepositFailure();
      }
    } on Exception catch (_) {
      yield DepositFailure();
    }
  }
}
