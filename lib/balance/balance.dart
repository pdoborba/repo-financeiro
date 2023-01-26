class Balance {
  String asset;
  num? free;
  num? locked;
  num? brlFree;
  num? brlLocked;

  Balance(this.asset, this.free, this.locked, this.brlFree, this.brlLocked);
  Balance.fromJson(Map json)
      : asset = json['asset'],
        free = json['free'],
        locked = json['locked'],
        brlFree = json['brlFree'],
        brlLocked = json['brlLocked'];
}
