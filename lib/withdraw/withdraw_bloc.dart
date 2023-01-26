import 'package:flutter_bloc/flutter_bloc.dart';
import 'repository/withdraw_repository.dart';
import 'withdraw_event.dart';
import 'withdraw_state.dart';

class WithdrawBloc extends Bloc<WithdrawEvent, WithdrawState> {
  final WithdrawRepository withdrawRepository;

  ///WithdrawBloc
  WithdrawBloc({
    required this.withdrawRepository,
  }) : super(WithdrawInitial());

  @override
  Stream<WithdrawState> mapEventToState(WithdrawEvent event) async* {
    if (event is WithdrawBrl) {
      yield* _mapWithdrawBrlToState(event.accountId, event.value, event.tax);
    } else if (event is WithdrawCoin) {
      yield* _mapWithdrawCoinToState(
          event.accountId, event.asset, event.network, event.value, event.tax);
    } else if (event is WithdrawLoad) {
      yield* _mapWithdrawLoadToState();
    } else if (event is WithdrawConfirm) {
      yield* _mapDepositConfirmToState(event.id);
    } else if (event is WithdrawCancel) {
      yield* _mapDepositConfirmToState(event.id);
    }
  }

  Stream<WithdrawState> _mapDepositCancelToState(String id) async* {
    try {
      yield WithdrawLoadInProgress();
      var result = await withdrawRepository.confirmWithdraw(id);
      if (result == true) {
        yield WithdrawConfirmSuccess();
      } else {
        yield WithdrawConfirmFailure();
      }
      yield* _mapWithdrawLoadToState();
    } on Exception catch (_) {
      yield WithdrawConfirmFailure();
    }
  }

  Stream<WithdrawState> _mapDepositConfirmToState(String id) async* {
    try {
      yield WithdrawLoadInProgress();
      var result = await withdrawRepository.confirmWithdraw(id);
      if (result == true) {
        yield WithdrawConfirmSuccess();
      } else {
        yield WithdrawConfirmFailure();
      }
      yield* _mapWithdrawLoadToState();
    } on Exception catch (_) {
      yield WithdrawConfirmFailure();
    }
  }

  Stream<WithdrawState> _mapWithdrawLoadToState() async* {
    try {
      yield WithdrawLoadInProgress();
      var result = await withdrawRepository.listWithdraws();
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      yield WithdrawLoadSuccess(result);
    } on Exception catch (_) {
      yield WithdrawLoadFailure();
    }
  }

  Stream<WithdrawState> _mapWithdrawBrlToState(
      String accountId, num value, num tax) async* {
    try {
      yield WithdrawInProgress();
      var result = await withdrawRepository.withdrawBrl(accountId, value, tax);
      if (result == true) {
        yield WithdrawSuccess();
      } else {
        yield WithdrawFailure();
      }
    } on Exception catch (_) {
      yield WithdrawFailure();
    }
  }

  Stream<WithdrawState> _mapWithdrawCoinToState(String accountId, String asset,
      String network, num value, num tax) async* {
    try {
      yield WithdrawInProgress();
      var result = await withdrawRepository.withdrawCoin(
          accountId, asset, network, value, tax);
      if (result == true) {
        yield WithdrawSuccess();
      } else {
        yield WithdrawFailure();
      }
    } on Exception catch (_) {
      yield WithdrawFailure();
    }
  }
}
