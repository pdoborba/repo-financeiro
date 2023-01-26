// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../withdraw/withdraw.dart';
import '../deposit/deposit.dart';

enum TransferStatus { CREATED, CONFIRMED, CANCELLED }

extension TransferStatusExtension on TransferStatus {
  Color get color {
    switch (this) {
      case TransferStatus.CREATED:
        return const Color(0xffBDD8F1);
      case TransferStatus.CONFIRMED:
        return const Color(0xffBDF1CE);
      case TransferStatus.CANCELLED:
        return const Color(0xffF5CFB6);
    }
  }

  String get title {
    switch (this) {
      case TransferStatus.CREATED:
        return 'Em Análise';
      case TransferStatus.CONFIRMED:
        return 'Concluído';
      case TransferStatus.CANCELLED:
        return 'Cancelado';
    }
  }
}

class Transfer {
  Withdraw? withdraw;
  Deposit? deposit;

  Transfer(this.withdraw, this.deposit);

  bool isWithdraw() {
    return withdraw != null;
  }

  String getTo() {
    if (withdraw != null) {
      return withdraw!.account?.cc ?? 'conta não encontrada';
    }
    return '';
  }

  String getStatus() {
    if (withdraw != null) {
      var status = WithdrawStatus.values[withdraw!.status.toInt()];
      switch (status) {
        case WithdrawStatus.REQUESTED:
          return TransferStatus.CREATED.name;
        case WithdrawStatus.DONE:
          return TransferStatus.CONFIRMED.name;
        case WithdrawStatus.REJECTED:
          return TransferStatus.CANCELLED.name;
      }
    } else if (deposit != null) {
      var status = DepositStatus.values[deposit!.status];
      switch (status) {
        case DepositStatus.REQUESTED:
          return TransferStatus.CREATED.name;
        case DepositStatus.DONE:
          return TransferStatus.CONFIRMED.name;
        case DepositStatus.REJECTED:
          return TransferStatus.CANCELLED.name;
      }
    }
    return TransferStatus.CREATED.name;
  }

  String getAsset() {
    if (withdraw != null) {
      return withdraw!.account!.type;
    } else if (deposit != null) {
      return deposit!.asset;
    }
    return '';
  }

  String getQty() {
    if (withdraw != null) {
      return withdraw!.amount.toString();
    } else if (deposit != null) {
      final formatCurrency = NumberFormat.simpleCurrency(locale: 'pt_BR');
      return formatCurrency.format(deposit!.amount);
    }
    return '';
  }

  String getTime() {
    if (withdraw != null) {
      return withdraw!.createdAt;
    } else if (deposit != null) {
      return deposit!.createdAt;
    }
    return '';
  }
}
