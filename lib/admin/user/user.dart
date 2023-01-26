class User {
  String id;
  String name;
  String email;
  String phone;

  User.fromJson(Map json)
      : id = json['id'] ?? '',
        name = json['name'] ?? '',
        email = json['email'] ?? '',
        phone = json['phone'] ?? '';
}
