import 'package:lpcapital/admin/user/user.dart';

enum DepositStatus { REQUESTED, DONE, REJECTED }

extension DepositStatusExtension on DepositStatus {
  String get name {
    switch (this) {
      case DepositStatus.REQUESTED:
        return 'Em Aberto';
      case DepositStatus.DONE:
        return 'Concluído';
      case DepositStatus.REJECTED:
        return 'Cancelado';
    }
  }
}

enum DepositType { TED, PIX }

class Deposit {
  String id;
  String email;
  String asset;
  num amount;
  int status;
  String createdAt;
  String type;
  User? user;

  Deposit.fromJson(Map json)
      : id = json['id'],
        email = json['email'],
        asset = json['asset'],
        amount = json['amount'],
        status = json['status'],
        createdAt = json['createdAt'],
        type = json['type'] ?? '',
        user = json['user'] != null ? User.fromJson(json['user']) : null;
}
