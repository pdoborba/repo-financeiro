class Network {
  String network;
  String coin;
  bool withdrawEnable;
  num withdrawFee;

  Network(this.network, this.coin, this.withdrawEnable, this.withdrawFee);
  Network.fromJson(Map json)
      : network = json['network'],
        coin = json['coin'],
        withdrawEnable = json['withdrawEnable'],
        withdrawFee = num.parse(json['withdrawFee']);
}
