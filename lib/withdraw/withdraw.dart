import 'package:lpcapital/account/account.dart';
import 'package:lpcapital/admin/user/user.dart';

enum WithdrawStatus { REQUESTED, DONE, REJECTED }

extension WithdrawStatusExtension on WithdrawStatus {
  String get name {
    switch (this) {
      case WithdrawStatus.REQUESTED:
        return 'Em Aberto';
      case WithdrawStatus.DONE:
        return 'Concluído';
      case WithdrawStatus.REJECTED:
        return 'Cancelado';
    }
  }
}

class Withdraw {
  String id;
  String email;
  String accountId;
  num amount;
  num status;
  num tax;
  String createdAt;
  String updatedAt;
  Account? account;

  Withdraw.fromJson(Map json)
      : id = json['id'] ?? '',
        email = json['email'] ?? '',
        accountId = json['accountId'] ?? '',
        amount = json['amount'] ?? 0,
        status = json['status'] ?? 0,
        tax = json['tax'] ?? 0,
        createdAt = json['createdAt'] ?? 0,
        updatedAt = json['updatedAt'] ?? 0,
        account =
            json['account'] != null ? Account.fromJson(json['account']) : null;
}
