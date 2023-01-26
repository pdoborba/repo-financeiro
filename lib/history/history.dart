import 'package:lpcapital/deposit/deposit.dart';
import 'package:lpcapital/withdraw/withdraw.dart';

class History {
  List<Deposit> deposits;
  List<Withdraw> withdraws;

  History.fromJson(Map json)
      : deposits = json['deposits'] != null
            ? (json['deposits'] as List)
                .map((i) => Deposit.fromJson(i))
                .toList()
            : [],
        withdraws = json['withdraws'] != null
            ? (json['withdraws'] as List)
                .map((i) => Withdraw.fromJson(i))
                .toList()
            : [];
}
