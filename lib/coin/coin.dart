// ignore_for_file: constant_identifier_names

enum Coin { BRL, BTC, ADA, XRP, ETH, USDT, MATIC, SOL }

extension CoinExtension on Coin {
  String get asset {
    switch (this) {
      case Coin.BRL:
        return 'assets/ic_brl.png';
      case Coin.BTC:
        return 'assets/ic_btc.png';
      case Coin.ADA:
        return 'assets/ic_ada.png';
      case Coin.XRP:
        return 'assets/ic_xrp.png';
      case Coin.MATIC:
        return 'assets/ic_matic.png';
      case Coin.USDT:
        return 'assets/ic_usdt.png';
      case Coin.ETH:
        return 'assets/ic_eth.png';
      case Coin.SOL:
        return 'assets/ic_sol.png';
    }
  }

  String get shortName {
    switch (this) {
      case Coin.BRL:
        return 'BRL';
      case Coin.BTC:
        return 'BTC';
      case Coin.ADA:
        return 'ADA';
      case Coin.XRP:
        return 'XRP';
      case Coin.ETH:
        return 'ETH';
      case Coin.USDT:
        return 'USDT';
      case Coin.MATIC:
        return 'MATIC';
      case Coin.SOL:
        return 'SOL';
    }
  }

  String get name {
    switch (this) {
      case Coin.BRL:
        return 'Real Brasileiro';
      case Coin.BTC:
        return 'BTC';
      case Coin.ADA:
        return 'ADA';
      case Coin.XRP:
        return 'XRP';
      case Coin.ETH:
        return 'ETH';
      case Coin.USDT:
        return 'USDT';
      case Coin.MATIC:
        return 'MATIC';
      case Coin.SOL:
        return 'SOL';
    }
  }
}
