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
    return User(
      id: json['id'] ?? Uuid().v4(),
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
