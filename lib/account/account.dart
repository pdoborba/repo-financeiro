// ignore_for_file: constant_identifier_names

import '../admin/user/user.dart';

enum AccountType { CORRENTE, POUPANCA, COIN }

extension AccountTypeExtension on AccountType {
  String get label {
    switch (this) {
      case AccountType.CORRENTE:
        return 'Conta Corrente';
      case AccountType.POUPANCA:
        return 'Poupança';
      case AccountType.COIN:
        return 'Moeda';
    }
  }
}

enum AccountLink { INDIVIDUAL, CONJUNTA }

extension AccountLinkExtension on AccountLink {
  String get label {
    switch (this) {
      case AccountLink.INDIVIDUAL:
        return 'Individual';
      case AccountLink.CONJUNTA:
        return 'Conjunta';
    }
  }
}

enum Banks { BRADESCO }

extension BankExtension on Banks {
  String get label {
    switch (this) {
      case Banks.BRADESCO:
        return 'Bradesco';
    }
  }
}

enum PixType { EMAIL, PHONE, ALEATORY, CPF }

extension PixTypeExtension on PixType {
  String get label {
    switch (this) {
      case PixType.EMAIL:
        return 'Email';
      case PixType.PHONE:
        return 'Telefone';
      case PixType.ALEATORY:
        return 'Aleatória';
      case PixType.CPF:
        return 'CPF';
    }
  }
}

class Account {
  String id;
  String email;
  String bank;
  String agency;
  String cc;
  String pixType;
  String pix;
  String type;
  String link;
  String createdAt;
  String updatedAt;
  User? user;

  Account(this.id, this.email, this.bank, this.agency, this.cc, this.pixType,
      this.pix, this.type, this.link, this.createdAt, this.updatedAt);

  Account.fromJson(Map json)
      : id = json['id'],
        email = json['email'],
        bank = json['bank'],
        agency = json['agency'],
        cc = json['cc'],
        pixType = json['pixType'],
        pix = json['pix'],
        type = json['type'],
        link = json['link'],
        user = json['user'] != null ? User.fromJson(json['user']) : null,
        createdAt = json['createdAt'],
        updatedAt = json['updatedAt'];

  String getBankName() {
    return Banks.values.byName(bank).label;
  }

  @override
  String toString() {
    var ret = '${getBankName()} - $cc / $agency';
    if (user != null) {
      ret += ' (${user!.name})';
    }
    return ret;
  }
}
