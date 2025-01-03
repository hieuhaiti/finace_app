import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String username;
  final String password;

  User({
    String? id,
    required this.username,
    required this.password,
  }) : id = id ?? Uuid().v4();

  factory User.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null ||
        json['username'] == null ||
        json['password'] == null) {
      throw ArgumentError('Missing required fields in User JSON');
    }
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
      };
}
