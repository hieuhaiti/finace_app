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

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        password: json['password'],
      );
}