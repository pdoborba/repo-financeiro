import 'package:lpcapital/network/network.dart';

class CoinNetwork {
  String coin;
  String name;
  List<Network> networkList;

  CoinNetwork(this.coin, this.name, this.networkList);
  CoinNetwork.fromJson(Map json)
      : coin = json['coin'],
        name = json['name'],
        networkList = json['networkList'] != null
            ? (json['networkList'] as List)
                .map((i) => Network.fromJson(i))
                .toList()
            : [];
}
